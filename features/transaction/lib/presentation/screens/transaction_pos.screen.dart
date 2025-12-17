import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/components/packet_card.dart';
import 'package:product/presentation/components/product_card.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/transaction_pos.controller.dart';

class TransactionPosScreen extends ConsumerStatefulWidget {
  const TransactionPosScreen({super.key});

  @override
  ConsumerState<TransactionPosScreen> createState() =>
      _TransactionPosScreenState();
}

class _TransactionPosScreenState extends ConsumerState<TransactionPosScreen> {
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _productGridController = ScrollController();
  late final TransactionPosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransactionPosController(ref, context);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _productGridController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);
    final filteredProducts =
        viewModel.getFilteredProducts(viewModel.cachedProducts);

    return Scaffold(
      appBar: AppBar(title: const Text('POS')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: _SearchBar(controller: _controller),
            ),
            _CategoryBar(
              controller: _controller,
              categoryScrollController: _categoryScrollController,
              productGridController: _productGridController,
              viewModel: viewModel,
              state: state,
            ),
            Expanded(
              child: _ContentArea(
                state: state,
                viewModel: viewModel,
                filteredProducts: filteredProducts,
                controller: _controller,
                productGridController: _productGridController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private, testable widgets extracted from TransactionPosScreen
// -----------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TransactionPosController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller.searchController,
            onChanged: (val) => controller.onSearchChanged(val: val),
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => controller.showFilterPopup(),
          icon: const Icon(Icons.filter_list, color: AppColors.sbBlue),
        ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final TransactionPosController controller;
  final ScrollController categoryScrollController;
  final ScrollController productGridController;
  final TransactionPosViewModel viewModel;
  final TransactionPosState state;

  const _CategoryBar({
    required this.controller,
    required this.categoryScrollController,
    required this.productGridController,
    required this.viewModel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // Categories ordering is provided by the ViewModel
    final categories = viewModel.orderedCategories;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          // Left filter button opens a modal to select categories
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Material(
              type: MaterialType.transparency,
              child: IconButton(
                onPressed: () async {
                  final selected = await showModalBottomSheet<String>(
                    context: context,
                    builder: (ctx) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: categories.map((name) {
                            final active = state.activeCategory == name;
                            return ListTile(
                              title: Text(name),
                              leading: active
                                  ? const Icon(Icons.check,
                                      color: AppColors.sbBlue)
                                  : null,
                              onTap: () => Navigator.of(ctx).pop(name),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                  if (selected != null) {
                    final idx = categories.indexOf(selected);
                    controller.onCategoryTap(
                      index: idx,
                      name: selected,
                      categoryScrollController: categoryScrollController,
                      productGridController: productGridController,
                    );
                  }
                },
                icon: const Icon(Icons.filter_list, color: AppColors.sbBlue),
              ),
            ),
          ),
          // Horizontal category list
          Expanded(
            child: ListView.separated(
              controller: categoryScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final name = categories[index];
                final active = state.activeCategory == name;
                return GestureDetector(
                  onTap: () => controller.onCategoryTap(
                    index: index,
                    name: name,
                    categoryScrollController: categoryScrollController,
                    productGridController: productGridController,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? AppColors.sbBlue : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: active
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: active ? Colors.white : Colors.grey[800],
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // fixed-width underline for active item
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: active ? 28 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.sbOrange : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  final TransactionPosState state;
  final TransactionPosViewModel viewModel;
  final List<ProductEntity> filteredProducts;
  final TransactionPosController controller;
  final ScrollController productGridController;

  const _ContentArea({
    required this.state,
    required this.viewModel,
    required this.filteredProducts,
    required this.controller,
    required this.productGridController,
  });

  @override
  Widget build(BuildContext context) {
    // loading -> show loading
    if (state.isLoading) return const _ContentLoading();

    // compute filtered packets
    final packetQuery = (state.searchQuery ?? '').toLowerCase();
    final filteredPackets = state.packets.where((p) {
      if (packetQuery.isEmpty) return true;
      return p.name != null && p.name!.toLowerCase().contains(packetQuery);
    }).toList();

    // empty -> show empty state
    if (filteredProducts.isEmpty && filteredPackets.isEmpty) {
      return const _ContentEmpty();
    }

    // otherwise show content
    return _ContentData(
      filteredPackets: filteredPackets,
      filteredProducts: filteredProducts,
      viewModel: viewModel,
      controller: controller,
      productGridController: productGridController,
    );
  }
}

class _ContentLoading extends StatelessWidget {
  const _ContentLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.sbBlue),
    );
  }
}

class _ContentEmpty extends StatelessWidget {
  const _ContentEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ContentData extends StatelessWidget {
  final List filteredPackets;
  final List<ProductEntity> filteredProducts;
  final TransactionPosViewModel viewModel;
  final TransactionPosController controller;
  final ScrollController productGridController;

  const _ContentData({
    required this.filteredPackets,
    required this.filteredProducts,
    required this.viewModel,
    required this.controller,
    required this.productGridController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredPackets.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(children: [
              Icon(Icons.layers, color: AppColors.sbBlue),
              SizedBox(width: 8),
              Text(
                'Paket',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ]),
          ),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredPackets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pkt = filteredPackets[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: PacketCard(
                    packet: pkt,
                    onTap: () => controller.showPacketSelection(
                        packet: pkt, products: viewModel.cachedProducts),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(child: Text("Produk tidak ditemukan"))
              : GridView.builder(
                  controller: productGridController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () => controller.onProductTap(product: product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
