import 'package:core/core.dart';
import 'package:transaction/presentation/sheets/cart_bottom.sheet.dart';
// view model is accessed via provider at runtime
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/screens/packet_selection.sheet.dart'
    show PacketSelectionSheet, SelectedPacketItem;
import 'package:transaction/presentation/widgets/filter_products_transaction.widget.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

class TransactionPosController {
  final WidgetRef ref;
  final BuildContext context;
  final TextEditingController searchController = TextEditingController();
  TransactionPosController(this.ref, this.context);

  void onShowCartSheet() {
    ref
        .read(transactionPosViewModelProvider.notifier)
        .setTypeCart(ETypeCart.main);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }

  // Called when the search text changes (UI delegates to controller)
  void onSearchChanged({required String val}) =>
      ref.read(transactionPosViewModelProvider.notifier).setSearchQuery(val);

  // Show filter popup and apply results to viewModel
  Future<void> showFilterPopup() async {
    final currentState = ref.read(transactionPosViewModelProvider);
    final vm = ref.read(transactionPosViewModelProvider.notifier);
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

  // Handle category tap: set active category and perform scrolling animations
  void onCategoryTap({
    required int index,
    required String name,
    required ScrollController productGridController,
    required ScrollController categoryScrollController,
  }) {
    ref.read(transactionPosViewModelProvider.notifier).setActiveCategory(name);

    // scroll category bar to keep selection visible
    const itemWidth = 110.0;
    final target = (index * (itemWidth + 8)) - 8;
    if (categoryScrollController.hasClients) {
      final max = categoryScrollController.position.maxScrollExtent;
      categoryScrollController.animateTo(target.clamp(0.0, max),
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    // scroll product grid to first product of category
    if (productGridController.hasClients) {
      final vm = ref.read(transactionPosViewModelProvider.notifier);
      final all = vm.getFilteredProducts(vm.cachedProducts);
      final idx = all.indexWhere((p) => (p.category?.name ?? 'All') == name);
      if (idx != -1) {
        final screenW = MediaQuery.of(context).size.width;
        final pItemWidth = (screenW - 32 - 12) / 2;
        final childHeight = pItemWidth / 0.75;
        final rowHeight = childHeight + 12;
        final row = (idx / 2).floor();
        final prodTarget = (row * rowHeight)
            .clamp(0.0, productGridController.position.maxScrollExtent);
        productGridController.animateTo(prodTarget,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    }
  }

  // Show packet selection sheet and forward selected items to viewModel
  Future<void> showPacketSelection(
      {required PacketEntity packet,
      required List<ProductEntity> products}) async {
    final selected = await showModalBottomSheet<List<SelectedPacketItem>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PacketSelectionSheet(packet: packet, products: products),
    );
    if (selected != null && selected.isNotEmpty) {
      await ref
          .read(transactionPosViewModelProvider.notifier)
          .addPacketSelection(packet: packet, selectedItems: selected);
    }
  }

  // Product tap: delegate to viewModel
  Future<void> onProductTap({required ProductEntity product}) async => await ref
      .read(transactionPosViewModelProvider.notifier)
      .onAddToCart(product);

  void dispose() {
    try {
      searchController.dispose();
    } catch (_) {}
  }
}
