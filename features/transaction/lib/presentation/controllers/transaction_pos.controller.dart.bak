import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/providers/product.provider.dart';
import 'package:transaction/presentation/sheets/cart_bottom.sheet.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';
import 'package:transaction/presentation/widgets/filter_products_transaction.widget.dart';
import 'package:product/presentation/screens/packet_selection.sheet.dart'
    show PacketSelectionSheet;
import 'package:product/domain/entities/packet_selected_item.entity.dart';

class TransactionPosController {
  final WidgetRef ref;
  final Logger _logger = Logger('TransactionPosController');
  final BuildContext context;
  final TextEditingController searchController = TextEditingController();

  /// AppBar search focus and UI state notifier (so screens remain stateless)
  late final FocusNode appBarSearchFocus;
  final ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);
  // Konstruktor controller: menyimpan referensi `ref` (Provider) dan
  // `context` (untuk memicu UI seperti dialog/sheet).
  // Gunakan timestamp untuk mencegah reload segera saat modal sheet
  // menutup dan membuka kembali. Jika terakhir refresh kurang dari
  // 2 detik lalu, abaikan refresh.
  DateTime? _lastRefreshAt;
  // Jika true maka abaikan satu kali refresh saat route terlihat kembali
  // (digunakan saat sheet ditutup agar tidak langsung merefresh data).
  bool _isCartSheetOpen = false;
  late final TransactionPosViewModel _vm;
  late TransactionPosState _state;

  TransactionPosController(this.ref, this.context);

  /// Enter search mode: set notifier and focus the search input.
  void enterSearch() {
    isSearching.value = true;
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          appBarSearchFocus.requestFocus();
        } catch (_) {}
      });
    } catch (_) {}
  }

  /// Exit search mode: clear input, reset notifier and notify ViewModel.
  void exitSearch() {
    isSearching.value = false;
    try {
      searchController.clear();
      onSearchChanged(val: '');
      appBarSearchFocus.unfocus();
    } catch (_) {}
  }

  // Initialize viewmodel and initial state. Caller should call
  // `attachListeners()` after widget build to start listening updates.
  void init() {
    _vm = ref.read(transactionPosViewModelProvider.notifier);
    _state = ref.read(transactionPosViewModelProvider);
    // initialize appbar focus node used by screens
    appBarSearchFocus = FocusNode();
    // Install product-after-CRUD hook at runtime (deferred) so we don't
    // modify providers during the widget build/init lifecycle. Use a
    // post-frame callback to perform the update after the first frame.
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          ref.read(productAfterCrudHookProvider.notifier).state = () {
            return _vm.refreshProducts();
          };
        } catch (_) {}
      });
    } catch (_) {}
  }

  /// Dipanggil oleh screen saat visibilitas route berubah (post-frame).
  /// Memastikan `refreshProductsAndPackets` hanya dijalankan sekali per
  /// kali visibilitas muncul.
  Future<void> maybeRefreshOnVisible(bool isCurrent) async {
    _logger.info(
        'maybeRefreshOnVisible dipanggil: isCurrent=$isCurrent, isCartSheetOpen=$_isCartSheetOpen');
    final now = DateTime.now();
    if (isCurrent) {
      // Jika kita baru saja melakukan refresh (misal karena sheet baru ditutup), lewati.
      if (_lastRefreshAt != null &&
          now.difference(_lastRefreshAt!).inSeconds < 2) {
        return;
      }
      // Pastikan transaksi pending lokal sudah dimuat terlebih dahulu agar tidak
      // melewatkan transaksi pending aktif yang dibuat di tempat lain.
      await _vm.ensureLocalPendingTransactionLoaded();
      await _vm.refreshProductsAndPackets();
      _lastRefreshAt = DateTime.now();
      return;
    }
  }

  void onShowCartBottomSheet() {
    // Prevent duplicate openings
    if (_isCartSheetOpen) return;
    _isCartSheetOpen = true;
    _vm.setTypeCart(ETypeCart.main);
    CartBottomSheet.open<void>(context).whenComplete(() {
      _isCartSheetOpen = false;
      // Tandai untuk mengabaikan satu kali refresh ketika sheet baru ditutup.
    });
  }

  // Dipanggil saat teks pencarian berubah (UI mendelegasikan ke controller)
  void onSearchChanged({required String val}) => _vm.setSearchQuery(val);

  // Tampilkan popup filter dan terapkan hasilnya ke ViewModel
  Future<void> showFilterPopup() async {
    final currentState = _state;
    final vm = _vm;
    final res = await showFilterProductsPopup(
      context,
      initialIncludePacket: false,
      categories: vm.availableCategories,
      initialCategoryName: currentState.activeCategory,
    );
    if (res != null) {
      vm.setActiveCategory(res.categoryName ?? 'Packet');
      if (res.includePacket) await vm.getPacketsList();
    }
  }

  // Tangani ketukan kategori: set active category dan lakukan animasi scroll
  void onCategoryTap({
    required int index,
    required String name,
    required ScrollController productGridController,
    required ScrollController categoryScrollController,
  }) {
    _vm.setActiveCategory(name);

    // Scroll bar kategori agar pilihan tetap terlihat
    const itemWidth = 110.0;
    final target = (index * (itemWidth + 8)) - 8;
    if (categoryScrollController.hasClients) {
      final max = categoryScrollController.position.maxScrollExtent;
      categoryScrollController.animateTo(target.clamp(0.0, max),
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    // Scroll grid produk ke produk pertama pada kategori — delegasikan
    // perhitungan indeks/offset ke ViewModel agar kepatuhan MVVM lebih ketat.
    if (productGridController.hasClients) {
      final vm = _vm;
      final idx = vm.indexOfFirstProductForCategory(name);
      if (idx != -1) {
        final screenW = MediaQuery.of(context).size.width;
        final rawTarget = vm.computeScrollTargetForIndex(idx, screenW);
        final prodTarget = rawTarget.clamp(
            0.0, productGridController.position.maxScrollExtent);
        productGridController.animateTo(prodTarget,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    }
  }

  // Tampilkan sheet pemilihan paket dan teruskan item terpilih ke ViewModel
  Future<void> showPacketSelection(
      {required PacketEntity packet,
      required List<ProductEntity> products}) async {
    final selected = await showModalBottomSheet<List<SelectedPacketItem>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PacketSelectionSheet(packet: packet, products: products),
    );
    if (selected != null && selected.isNotEmpty) {
      await _vm.addPacketSelection(packet: packet, selectedItems: selected);
    }
  }

  // Ketuk produk: delegasikan aksi ke ViewModel
  Future<void> onProductTap({required ProductEntity product}) async =>
      await _vm.onAddToCart(product);

  /// Ketuk produk dengan perilaku pintar: jika produk sudah ada di
  /// `transaction details`, buka Cart Bottom Sheet. Jika belum ada,
  /// tambahkan ke keranjang.
  Future<void> onProductTapSmart({required ProductEntity product}) async {
    final state = ref.read(transactionPosViewModelProvider);
    final pid = product.id ?? 0;
    final exists = state.details.any((d) => (d as dynamic).productId == pid);
    if (exists) {
      onShowCartBottomSheet();
      return;
    }
    await onProductTap(product: product);
  }

  // Bersihkan resource saat controller tidak lagi dipakai (dispose)
  // Disini hanya melepaskan `searchController`.
  void dispose() {
    try {
      searchController.dispose();
    } catch (_) {}
    try {
      appBarSearchFocus.dispose();
    } catch (_) {}
    try {
      isSearching.dispose();
    } catch (_) {}
  }
}
