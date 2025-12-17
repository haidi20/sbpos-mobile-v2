import 'package:core/core.dart';
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
  final FocusNode _appBarSearchFocus = FocusNode();
  bool _isSearching = false;

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
    _appBarSearchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller.searchController,
                      focusNode: _appBarSearchFocus,
                      onChanged: (v) => _controller.onSearchChanged(val: v),
                      decoration: const InputDecoration(
                        hintText: 'Cari produk...',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              )
            : const Text('POS Produk'),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                  });
                  // clear search and reset filter
                  try {
                    _controller.searchController.clear();
                    _controller.onSearchChanged(val: '');
                  } catch (_) {}
                },
              )
            : null,
        actions: _isSearching
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      try {
                        _appBarSearchFocus.requestFocus();
                      } catch (_) {}
                    });
                  },
                ),
              ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _CategoryBar(
              controller: _controller,
              categoryScrollController: _categoryScrollController,
              productGridController: _productGridController,
              viewModel: viewModel,
              state: state,
            ),
            Expanded(
              child: _ContentArea(
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

// Note: `_SearchBar` was previously declared here but is not used; removed
// to keep analyzer clean. The AppBar now uses an inline search `TextField`.

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
                    isScrollControlled: true,
                    builder: (ctx) {
                      return SafeArea(
                        child: SizedBox(
                          // constrain max height to half screen to avoid overflow
                          height: MediaQuery.of(ctx).size.height * 0.5,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: categories.length,
                            itemBuilder: (context, i) {
                              final name = categories[i];
                              final active = state.activeCategory == name;
                              return ListTile(
                                title: Text(name),
                                leading: active
                                    ? const Icon(Icons.check,
                                        color: AppColors.sbBlue)
                                    : null,
                                onTap: () => Navigator.of(ctx).pop(name),
                              );
                            },
                          ),
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
                          color: active ? Colors.grey[300] : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: active
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            name,
                            style: TextStyle(
                              color:
                                  active ? Colors.grey[600] : Colors.grey[800],
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
                          color: active ? AppColors.sbBlue : Colors.transparent,
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

class _ContentArea extends ConsumerWidget {
  final TransactionPosController controller;
  final ScrollController productGridController;

  const _ContentArea({
    required this.controller,
    required this.productGridController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

    // loading -> show loading
    if (state.isLoading) return const _ContentLoading();

    // compute filteredProducts and packets from viewModel/state
    final filteredProducts =
        viewModel.getFilteredProducts(viewModel.cachedProducts);
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
      controller: controller,
      productGridController: productGridController,
    );
  }
}

class _ContentLoading extends StatelessWidget {
  const _ContentLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(
        child: CircularProgressIndicator(color: AppColors.sbBlue),
      ),
    );
  }
}

class _ContentEmpty extends StatelessWidget {
  const _ContentEmpty();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Produk tidak ditemukan',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ContentData extends ConsumerWidget {
  final TransactionPosController controller;
  final ScrollController productGridController;

  const _ContentData({
    required this.controller,
    required this.productGridController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

    final filteredProducts =
        viewModel.getFilteredProducts(viewModel.cachedProducts);
    final packetQuery = (state.searchQuery ?? '').toLowerCase();
    final filteredPackets = state.packets.where((p) {
      if (packetQuery.isEmpty) return true;
      return p.name != null && p.name!.toLowerCase().contains(packetQuery);
    }).toList();

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
                    mainAxisSpacing: 12,
                  ),
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
