import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/presentation/sheets/cart_bottom.sheet.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/widgets/filter_products_transaction.widget.dart';
import 'package:product/presentation/screens/packet_selection.sheet.dart'
    show PacketSelectionSheet, SelectedPacketItem;

class TransactionPosController {
  final WidgetRef ref;
  final BuildContext context;
  final TextEditingController searchController = TextEditingController();
  // Konstruktor controller: menyimpan referensi `ref` (Provider) dan
  // `context` (untuk memicu UI seperti dialog/sheet).
  // Flag internal untuk melacak visibilitas dan status sheet agar UI tetap sederhana
  bool _didRefreshOnVisible = false;
  bool _isCartSheetOpen = false;
  late final TransactionPosViewModel _vm;
  late TransactionPosState _state;

  TransactionPosController(this.ref, this.context);

  // Initialize viewmodel and initial state. Caller should call
  // `attachListeners()` after widget build to start listening updates.
  void init() {
    _vm = ref.read(transactionPosViewModelProvider.notifier);
    _state = ref.read(transactionPosViewModelProvider);
  }

  /// Dipanggil oleh screen saat visibilitas route berubah (post-frame).
  /// Memastikan `refreshProductsAndPackets` hanya dijalankan sekali per
  /// kali visibilitas muncul.
  Future<void> maybeRefreshOnVisible(bool isCurrent) async {
    if (isCurrent && !_didRefreshOnVisible) {
      await _vm.refreshProductsAndPackets();
      _didRefreshOnVisible = true;
    }
    if (!isCurrent) {
      _didRefreshOnVisible = false;
    }
  }

  void onShowCartSheet() {
    // Prevent duplicate openings
    if (_isCartSheetOpen) return;
    _isCartSheetOpen = true;
    _vm.setTypeCart(ETypeCart.main);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    ).whenComplete(() => _isCartSheetOpen = false);
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

  // Bersihkan resource saat controller tidak lagi dipakai (dispose)
  // Disini hanya melepaskan `searchController`.
  void dispose() {
    try {
      searchController.dispose();
    } catch (_) {}
  }
}
