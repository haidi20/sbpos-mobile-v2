import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/presentation/ui_models/order_type_item.um.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/helpers/order_type_icon.helper.dart';
import 'package:transaction/data/dummy/order_type_dummy.dart';
import 'package:transaction/presentation/view_models/transaction_pos.calculations.dart';
import 'package:transaction/presentation/view_models/transaction_pos.persistence.dart';

class TransactionPosViewModel extends StateNotifier<TransactionPosState> {
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetTransactionActive _getTransactionActive;
  final _logger = Logger('TransactionPosViewModel');
  late final TransactionPersistence _persistence;
  // Debounce timers for note updates
  Timer? _orderNoteDebounce;
  final Map<int, Timer> _itemNoteDebounces = {};

  // Membuat `TransactionPosViewModel` dan memulai pemuatan transaksi lokal.
  // Memanggil `_loadLocalTransaction()` saat inisialisasi untuk mengisi state
  // dari data transaksi yang tersimpan secara offline jika ada.
  TransactionPosViewModel(
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
    this._getTransactionActive,
  ) : super(TransactionPosState()) {
    // initialize persistence service and load existing transaction from local DB
    _persistence = TransactionPersistence(
      _createTransaction,
      _updateTransaction,
      _deleteTransaction,
      _logger,
    );
    _loadLocalTransaction();
  }

  // ------------------ Getters ------------------
  // Mengembalikan daftar `TransactionDetailEntity` yang sudah difilter
  // berdasarkan `searchQuery` dan `activeCategory` untuk tampilan UI.
  List<TransactionDetailEntity> get getFilteredDetails {
    final query = state.searchQuery?.toLowerCase() ?? "";
    final category = state.activeCategory;

    return state.details.where((item) {
      final matchesQuery =
          item.productName?.toLowerCase().contains(query) ?? false;
      final matchesCategory = category == "All" ||
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
          category == "All" || (p.category?.name ?? '') == category;
      final matchesSearch = searchQuery.isEmpty ||
          (p.name != null && p.name!.toLowerCase().contains(searchQuery));
      return matchesCategory && matchesSearch;
    }).toList();
  }

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

    // persist to DB first, update state after success
    await _persistence.persistAndUpdateState(
        () => state, (s) => state = s, updated);
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

  // ------------------ Helper Privat ------------------
  // Persist detail yang sudah diupdate (dan opsional: catatan) ke DB lokal terlebih dahulu,
  // lalu update state hanya jika penyimpanan berhasil.
  // Helper privat yang melakukan persist (create/update/delete) pada
  // transaksi dan detailnya ke database lokal, lalu memperbarui state
  // ketika operasi sukses. Parameter `orderNote` dan `forceStatus`
  // dapat dipakai untuk menimpa nilai saat persist.

  // attempt to load existing transaction from local db using isOffline=true
  // Mencoba memuat transaksi aktif dari database lokal pada saat
  // inisialisasi ViewModel. Jika ditemukan, state akan diisi dengan data itu.
  Future<void> _loadLocalTransaction() async {
    _logger.info('_loadLocalTransaction: starting load from local DB...');
    try {
      // fetch the single active/latest transaction (created desc, limit 1)
      final res = await _getTransactionActive.call(isOffline: true);
      res.fold((f) {
        // silently ignore failures for init
        _logger
            .info('_loadLocalTransaction: no existing local transaction found');
      }, (tx) {
        _logger.info(
            'Loaded local transaction, details length: ${tx.details?.length ?? 0}');
        state = state.copyWith(transaction: tx, details: tx.details ?? []);
      });
    } catch (e) {
      // ignore init load errors
    }
  }
}
