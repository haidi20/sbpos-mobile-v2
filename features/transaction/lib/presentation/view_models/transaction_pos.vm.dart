import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/presentation/ui_models/order_type_item.um.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:product/presentation/screens/packet_selection.sheet.dart'
    show SelectedPacketItem;
import 'package:product/domain/usecases/get_packets.usecase.dart';
import 'package:transaction/presentation/helpers/order_type_icon.helper.dart';
import 'package:transaction/data/dummy/order_type_dummy.dart';
import 'package:transaction/presentation/view_models/transaction_pos.calculations.dart';
import 'package:transaction/presentation/view_models/transaction_pos.persistence.dart';
import 'package:transaction/domain/entitties/content_item.entity.dart';

// Usecase Product/Paket disediakan oleh composition root (provider)
// dan diinjeksi ke ViewModel ini. Jangan membuat repository palsu di sini.

class TransactionPosViewModel extends StateNotifier<TransactionPosState> {
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetTransactionActive _getTransactionActive;
  late final GetPackets? _getPacketsUsecase;
  late final GetProducts? _getProductsUsecase;
  List<ProductEntity> _cachedProducts = [];
  List<ProductEntity> get cachedProducts => _cachedProducts;
  final _logger = Logger('TransactionPosViewModel');
  late final TransactionPersistence _persistence;
  // Timer debounce untuk pembaruan catatan (note)
  Timer? _orderNoteDebounce;
  final Map<int, Timer> _itemNoteDebounces = {};

  TransactionPosViewModel(
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
    this._getTransactionActive, [
    GetPackets? getPackets,
    GetProducts? getProducts,
  ]) : super(TransactionPosState()) {
    // Inisialisasi layanan persistensi dan muat transaksi lokal dari database
    _persistence = TransactionPersistence(
      _createTransaction,
      _updateTransaction,
      _deleteTransaction,
      _logger,
    );
    _getPacketsUsecase = getPackets;
    _getProductsUsecase = getProducts;

    // Load local transaction and initial data
    // pemanggilan async di konstruktor secara berurutan
    (() async {
      await _persistence.loadLocalTransaction(
        _getTransactionActive,
        () => state,
        (s) => state = s,
      );
      await getPacketsList();
      await _loadProductsAndCategories();
    })();
  }

  Future<void> _loadProductsAndCategories() async {
    try {
      if (_getProductsUsecase == null) {
        _logger.info('no products usecase provided');
        _cachedProducts = [];
        if (state.activeCategory.isEmpty) {
          state = state.copyWith(activeCategory: 'Semua');
        }
        return;
      }

      final res = await _getProductsUsecase(isOffline: true);
      res.fold((f) {
        _logger.info('no products loaded');
        _cachedProducts = [];
      }, (list) {
        _cachedProducts = list;
        if (state.activeCategory.isEmpty) {
          state = state.copyWith(activeCategory: 'Semua');
        }
      });
    } catch (e, st) {
      _logger.warning('load products/categories error: $e', e, st);
    }
  }

  List<String> get availableCategories {
    final set = <String>{'Paket'};
    for (final p in _cachedProducts) {
      final n = p.category?.name;
      if (n != null && n.isNotEmpty) set.add(n);
    }
    return set.toList();
  }

  /// Categories ordered for UI: always 'Semua' first, then 'Paket', then others.
  List<String> get orderedCategories {
    final others =
        availableCategories.where((c) => c.toLowerCase() != 'paket').toList();
    return <String>['Semua', 'Paket', ...others];
  }

  Future<void> getPacketsList({String? query}) async {
    try {
      if (_getPacketsUsecase == null) {
        _logger.info('no packets usecase provided');
        state = state.copyWith(packets: []);
        return;
      }

      final res = await _getPacketsUsecase(isOffline: true, query: query);
      res.fold((f) {
        _logger.warning('getPacketsList failed: $f');
      }, (list) {
        state = state.copyWith(packets: list);
      });
    } catch (e, st) {
      _logger.warning('getPacketsList exception: $e', e, st);
    }
  }

  /// Metode publik untuk menyegarkan paket dan produk secara offline.
  Future<void> refreshProductsAndPackets({String? packetQuery}) async {
    await getPacketsList(query: packetQuery);
    await _loadProductsAndCategories();
  }

  // ------------------ Pengambil (Getters) ------------------
  // Mengembalikan daftar `TransactionDetailEntity` yang sudah difilter
  // berdasarkan `searchQuery` dan `activeCategory` untuk tampilan UI.
  List<TransactionDetailEntity> get getFilteredDetails {
    final query = state.searchQuery?.toLowerCase() ?? "";
    final category = state.activeCategory;

    return state.details.where((item) {
      final matchesQuery =
          item.productName?.toLowerCase().contains(query) ?? false;
      final matchesCategory = category == "Semua" ||
          (item.note?.toLowerCase() == category.toLowerCase());
      return matchesQuery && matchesCategory;
    }).toList();
  }

  // Menghasilkan list tipe order (Map) yang siap dipakai oleh UI selector.
  List<Map<String, Object?>> get getOrderTypes {
    return orderTypeDummies.map((m) {
      final id = (m.idServer ?? m.id)?.toString() ?? m.name;
      return {
        'id': id,
        'label': m.name,
        'icon': resolveOrderTypeIcon(m.icon),
      };
    }).toList();
  }

  // Mengembalikan total keranjang dalam format rupiah sebagai `String`.
  String get getCartTotal {
    final total = calculateCartTotal(state.details);
    return formatRupiah(total.toDouble());
  }

  // Menghitung total jumlah item (kuantitas) di dalam keranjang.
  int get getCartCount => calculateCartCount(state.details);

  // Menghitung total nilai keranjang sebagai `int` (tanpa format).
  // Digunakan untuk perhitungan internal (tax, grand total, dll.).
  int get getCartTotalValue {
    return calculateCartTotalValue(state.details);
  }

  // Menghitung pajak (10%) dari total keranjang.
  int get getTaxValue {
    return calculateTaxValue(state.details);
  }

  // Menghitung grand total (total + pajak).
  int get getGrandTotalValue => getCartTotalValue + getTaxValue;

  // Menghitung kembalian berdasarkan `state.cashReceived` dikurangi
  // `getGrandTotalValue`.
  int get getChangeValue {
    return calculateChangeValue(state.cashReceived, state.details);
  }

  // Mengonversi `getOrderTypes` menjadi list `OrderTypeItemUiModel`
  // untuk ditampilkan pada selector tipe order di UI.
  List<OrderTypeItemUiModel> getOrderTypeItems() {
    final raw = getOrderTypes; // List<Map<String, Object?>
    return raw.map((m) {
      final id = (m['id'] as String);
      final label = (m['label'] as String);
      final icon = (m['icon'] as IconData);
      final selected =
          (id == 'dine_in' && state.orderType == EOrderType.dineIn) ||
              (id == 'take_away' && state.orderType == EOrderType.takeAway) ||
              (id == 'online' && state.orderType == EOrderType.online);

      return OrderTypeItemUiModel(
        id: id,
        icon: icon,
        label: label,
        selected: selected,
      );
    }).toList();
  }

  // Mengembalikan daftar produk yang sudah difilter berdasarkan state POS.
  //
  // Filter meliputi `activeCategory` dan `searchQuery` sehingga UI bisa
  // meminta daftar produk yang sudah disesuaikan dengan kondisi saat ini.
  List<ProductEntity> getFilteredProducts(List<ProductEntity> products) {
    final category = state.activeCategory;
    final searchQuery = state.searchQuery?.toLowerCase() ?? '';

    return products.where((p) {
      final matchesCategory =
          category == "Semua" || (p.category?.name ?? '') == category;
      final matchesSearch = searchQuery.isEmpty ||
          (p.name != null && p.name!.toLowerCase().contains(searchQuery));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Filter paket menggunakan `state.searchQuery` saat ini
  List<PacketEntity> getFilteredPackets([String? query]) {
    final packetQuery = (query ?? state.searchQuery ?? '').toLowerCase();
    return state.packets.where((p) {
      if (packetQuery.isEmpty) return true;
      return p.name != null && p.name!.toLowerCase().contains(packetQuery);
    }).toList();
  }

  // Menggabungkan item konten untuk UI: bisa berupa paket atau produk.
  // Urutan: paket terlebih dulu, kemudian produk (keduanya sudah difilter).
  List<ContentItemEntity> getCombinedContent() {
    final packets = getFilteredPackets();
    final products = getFilteredProducts(_cachedProducts);

    final List<ContentItemEntity> out = [];
    for (final pkt in packets) {
      out.add(ContentItemEntity.packet(pkt));
    }
    for (final prod in products) {
      out.add(ContentItemEntity.product(prod));
    }
    return out;
  }

  /// Returns the index of the first product in the filtered product list
  /// that matches the given category `name`. Returns -1 when not found.
  int indexOfFirstProductForCategory(String name) {
    final all = getFilteredProducts(_cachedProducts);
    return calcIndexOfFirstProductForCategory(all, name);
  }

  /// Compute vertical scroll target (in pixels) for a product index.
  /// Uses the same layout assumptions as the UI grid: horizontal
  /// padding 16 on each side (total 32), crossAxisSpacing `spacing`, and
  /// `columns` columns with `childAspectRatio`.
  double computeScrollTargetForIndex(
    int index,
    double screenWidth, {
    int columns = 2,
    double horizontalPadding = 32.0,
    double spacing = 12.0,
    double childAspectRatio = 0.75,
  }) {
    return calcComputeScrollTargetForIndex(
      index,
      screenWidth,
      columns: columns,
      horizontalPadding: horizontalPadding,
      spacing: spacing,
      childAspectRatio: childAspectRatio,
    );
  }

// (ContentItem moved to file bottom to keep it top-level)
  // Pilih `EOrderType` berdasarkan `id` string dari UI.
  void selectOrderTypeById(String id) {
    final type = id == 'dine_in'
        ? EOrderType.dineIn
        : id == 'take_away'
            ? EOrderType.takeAway
            : EOrderType.online;
    setOrderType(type);
  }

  // ------------------ Setters / Mutators ------------------
  // Menambah atau mengurangi kuantitas produk pada detail berdasarkan
  // `productId` dan `valueAddQty`, lalu menyimpan perubahan ke database lokal.
  Future<void> setUpdateQuantity(int productId, int valueAddQty) async {
    final index =
        state.details.indexWhere((item) => item.productId == productId);
    if (index == -1) return;

    final updated = List<TransactionDetailEntity>.from(state.details);
    // Defensive check
    if (index < 0 || index >= updated.length) return;
    final old = updated[index];
    final newQty = (old.qty ?? 0) + valueAddQty;
    if (newQty <= 0) {
      updated.removeAt(index);
    } else {
      final price = old.productPrice ?? 0;

      updated[index] = old.copyWith(
        qty: newQty,
        subtotal: price * newQty,
      );
    }

    // persist to DB first, then update state when success
    await _persistence.persistAndUpdateState(
        () => state, (s) => state = s, updated);
  }

  // Update Item Note with debounce to avoid rapid DB writes
  // Menyimpan catatan untuk item tertentu dengan debounce untuk
  // mengurangi frekuensi penulisan ke database.
  Future<void> setItemNote(int productId, String note) async {
    final index = state.details.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    // Update local state immediately for responsive UI
    final updatedLocal = List<TransactionDetailEntity>.from(state.details);
    final old = updatedLocal[index];
    updatedLocal[index] = old.copyWith(note: note);
    state = state.copyWith(details: updatedLocal);

    // Debounce persistence per item
    _itemNoteDebounces[productId]?.cancel();
    _itemNoteDebounces[productId] =
        Timer(const Duration(milliseconds: 400), () {
      unawaited(_persistence.persistAndUpdateState(() => state,
          (s) => state = s, List<TransactionDetailEntity>.from(state.details)));
    });
  }

  // Set Order Note with debounce; avoid re-writing details on every keystroke
  // Menyimpan catatan order (order note) dengan debounce; update state
  // langsung untuk responsif dan persist setelah delay.
  Future<void> setOrderNote(String note) async {
    // Update local state immediately for UI
    state = state.copyWith(orderNote: note);

    // Debounce persistence
    _orderNoteDebounce?.cancel();
    _orderNoteDebounce = Timer(const Duration(milliseconds: 500), () {
      final updatedDetails = List<TransactionDetailEntity>.from(state.details);
      unawaited(_persistence.persistAndUpdateState(
          () => state, (s) => state = s, updatedDetails,
          orderNote: state.orderNote));
    });
  }

  // Menetapkan `selectedCustomer` pada state; jika `null` maka menghapus
  // customer yang dipilih sambil mempertahankan bagian state lain.
  void setCustomer(CustomerEntity? customer) {
    if (customer == null) {
      // Use factory that preserves all other fields and clears customer only
      state = state.clear(clearSelectedCustomer: true);
      return;
    } else {
      state = state.copyWith(selectedCustomer: customer);
    }
  }

  // Set active category
  // Set kategori aktif untuk filter produk dan persist perubahan.
  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
    unawaited(_persistence.persistAndUpdateState(() => state, (s) => state = s,
        List<TransactionDetailEntity>.from(state.details)));
  }

  // Set search query
  // Set query pencarian yang digunakan untuk memfilter `details`.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set Active Note ID
  // Set atau clear `activeNoteId` di state.
  void setActiveNoteId(int? id) {
    if (id == null) {
      state = state.clear(clearActiveNoteId: true);

      return;
    }
    state = state.copyWith(activeNoteId: id);
  }

  // Mengatur tipe tampilan cart (`ETypeCart`) di state.
  void setTypeCart(ETypeCart type) {
    state = state.copyWith(typeCart: type);
  }

  // UI setters for payment/order flow
  // Mengubah tipe order (dineIn/takeAway/online) dan menyimpan perubahan
  // ke database lokal.
  void setOrderType(EOrderType type) {
    state = state.copyWith(orderType: type);
    // persist change to local DB using current details
    unawaited(_persistence.persistAndUpdateState(() => state, (s) => state = s,
        List<TransactionDetailEntity>.from(state.details)));
  }

  // Menetapkan provider ojol untuk order online dan persist ke DB.
  void setOjolProvider(String provider) {
    state = state.copyWith(ojolProvider: provider);
    unawaited(_persistence.persistAndUpdateState(() => state, (s) => state = s,
        List<TransactionDetailEntity>.from(state.details)));
  }

  // Menetapkan metode pembayaran dan menyimpan perubahan ke DB.
  void setPaymentMethod(EPaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
    unawaited(
      _persistence.persistAndUpdateState(
        () => state,
        (s) => state = s,
        List<TransactionDetailEntity>.from(state.details),
      ),
    );
  }

  // Menetapkan flag langsung bayar (isPaid) dan persist ke DB.
  void setIsPaid(bool v) {
    state = state.copyWith(isPaid: v);
    unawaited(_persistence.persistAndUpdateState(() => state, (s) => state = s,
        List<TransactionDetailEntity>.from(state.details)));
  }

  // Menetapkan jumlah tunai yang diterima dan persist perubahan.
  void setCashReceived(int amount) {
    state = state.copyWith(cashReceived: amount);
    unawaited(_persistence.persistAndUpdateState(() => state, (s) => state = s,
        List<TransactionDetailEntity>.from(state.details)));
  }

  // Mengatur mode tampilan view (`cart` atau `checkout`).
  void setViewMode(EViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  // Tampilkan atau sembunyikan snackbar error sesuai nilai `v`.
  void setShowErrorSnackbar(bool v) {
    state = state.copyWith(showErrorSnackbar: v);
  }

  // ------------------ Actions (on*) ------------------
  // Menambahkan produk ke keranjang; jika sudah ada maka menambah kuantitas.
  // Perubahan dipersist ke database lewat helper privat.
  Future<void> onAddToCart(ProductEntity product) async {
    final index = state.details.indexWhere((d) => d.productId == product.id);
    List<TransactionDetailEntity> updated;
    if (index != -1) {
      updated = List<TransactionDetailEntity>.from(state.details);
      final old = updated[index];
      final newQty = (old.qty ?? 0) + 1;
      updated[index] = old.copyWith(
        qty: newQty,
        subtotal: (old.productPrice ?? product.price?.toInt() ?? 0) * newQty,
      );
    } else {
      final newDetail = TransactionDetailEntity(
        productId: product.id,
        productName: product.name,
        productPrice: product.price?.toInt(),
        qty: 1,
        subtotal: product.price?.toInt(),
        transactionId: state.transaction?.id,
      );
      updated = List<TransactionDetailEntity>.from(state.details)
        ..add(newDetail);
      // _logger.info("details length", updated.length.toString());
    }

    // _logger.info("adding to cart, total items: ${updated.length}");

    // Update state segera untuk UI responsif, tapi persist hanya di background
    // tanpa memaksa refresh state dari persistence.
    state = state.copyWith(details: updated);
    unawaited(_persistence.persistOnly(state, updated));
  }

  // Menambahkan packet ke keranjang; jika sudah ada maka menambah kuantitas.
  Future<void> onAddPacketToCart({required PacketEntity packet}) async {
    final index = state.details.indexWhere((d) => d.packetId == packet.id);
    List<TransactionDetailEntity> updated;
    if (index != -1) {
      updated = List<TransactionDetailEntity>.from(state.details);
      final old = updated[index];
      final newQty = (old.qty ?? 0) + 1;
      updated[index] = old.copyWith(
        qty: newQty,
        subtotal: (old.packetPrice ?? packet.price ?? 0) * newQty,
      );
    } else {
      final newDetail = TransactionDetailEntity(
        packetId: packet.id,
        packetName: packet.name,
        packetPrice: packet.price,
        qty: 1,
        subtotal: packet.price,
        transactionId: state.transaction?.id,
      );
      updated = List<TransactionDetailEntity>.from(state.details)
        ..add(newDetail);
    }

    await _persistence.persistAndUpdateState(
        () => state, (s) => state = s, updated);
  }

  // Add multiple transaction details (e.g., selected items from a packet)
  Future<void> onAddPacketItems(
      List<TransactionDetailEntity> detailsToAdd) async {
    final updated = List<TransactionDetailEntity>.from(state.details);

    for (final d in detailsToAdd) {
      final index = updated.indexWhere((e) => e.productId == d.productId);
      if (index != -1) {
        final old = updated[index];
        final newQty = (old.qty ?? 0) + (d.qty ?? 1);
        updated[index] = old.copyWith(
          qty: newQty,
          subtotal: (old.productPrice ?? d.productPrice ?? 0) * newQty,
        );
      } else {
        updated.add(d);
      }
    }

    await _persistence.persistAndUpdateState(
        () => state, (s) => state = s, updated);
  }

  // Create TransactionDetailEntity from packet selection (productId + qty)
  Future<void> addPacketSelection({
    required PacketEntity packet,
    required List<SelectedPacketItem> selectedItems,
  }) async {
    final details = <TransactionDetailEntity>[];
    for (final s in selectedItems) {
      final pid = s.productId;
      final qty = s.qty;
      final prod = _cachedProducts.firstWhere((p) => p.id == pid,
          orElse: () => ProductEntity(id: pid));
      final price = prod.price?.toInt() ?? 0;
      details.add(TransactionDetailEntity(
        transactionId: state.transaction?.id ?? 0,
        productId: prod.id,
        productName: prod.name,
        productPrice: price,
        packetId: packet.id,
        packetName: packet.name,
        qty: qty,
        subtotal: (price * qty).toInt(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    if (details.isNotEmpty) await onAddPacketItems(details);
  }

  // Menyimpan/transaksi final (onStore) dengan memaksa status menjadi
  // `proses` lalu mem-persist data ke DB lokal.
  Future<void> onStore({ProductEntity? product}) async {
    await _persistence.persistAndUpdateState(() => state, (s) => state = s,
        List<TransactionDetailEntity>.from(state.details),
        // set status to proses when explicitly storing/processing the order
        forceStatus: TransactionStatus.proses);
  }

  // Mengatur transisi `typeCart` ketika pengguna menavigasi alur
  // pemilihan metode pembayaran (main -> confirm -> checkout).
  Future<void> onShowMethodPayment() async {
    final ETypeCart current = state.typeCart;

    if (current == ETypeCart.main) {
      state = state.copyWith(typeCart: ETypeCart.confirm);
    } else if (current == ETypeCart.confirm) {
      state = state.copyWith(typeCart: ETypeCart.checkout);
    } else {
      state = state.copyWith(typeCart: ETypeCart.checkout);
    }
  }

  // Toggle `viewMode` antara cart dan checkout.
  void onToggleView() {
    final next =
        state.viewMode == EViewMode.cart ? EViewMode.checkout : EViewMode.cart;

    setViewMode(next);
  }

  // Clear Cart — use DeleteTransaction usecase for existing local transaction
  // Membersihkan keranjang. Jika ada transaksi lokal maka akan menghapusnya
  // lewat usecase `DeleteTransaction`, jika tidak maka hanya mereset state.
  Future<void> onClearCart() async {
    try {
      state = state.copyWith(isLoading: true);

      final txId = state.transaction?.id;
      if (txId != null) {
        final res = await _deleteTransaction.call(txId, isOffline: true);
        res.fold((f) {
          state = state.copyWith(error: f.toString(), isLoading: false);
        }, (ok) {
          state = TransactionPosState.cleared();
        });
        return;
      }

      // No transaction to delete; just clear local state
      state = TransactionPosState.cleared();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Reset seluruh state POS ke kondisi awal.
  void onClearAll() {
    state = TransactionPosState.cleared();
  }
}
