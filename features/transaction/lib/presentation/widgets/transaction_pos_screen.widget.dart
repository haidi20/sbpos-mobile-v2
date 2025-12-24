import 'package:core/core.dart';
import 'package:product/presentation/components/packet_card.dart';
import 'package:product/presentation/components/product_card.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/controllers/transaction_pos.controller.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';

// Public widgets extracted from TransactionPosScreen

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class CartBottomButton extends StatelessWidget {
  final TransactionPosState state;
  final TransactionPosViewModel viewModel;
  final VoidCallback onTap;

  const CartBottomButton({
    super.key,
    required this.state,
    required this.viewModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state.details.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.sbBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.sbBlue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        Positioned(
                          right: -5,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.sbOrange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.sbBlue,
                                width: 1,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                "${viewModel.getCartCount}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            viewModel.getCartTotal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Text(
                    "Keranjang",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final TransactionPosController controller;
  final ScrollController categoryScrollController;
  final ScrollController productGridController;
  final TransactionPosViewModel viewModel;
  final TransactionPosState state;

  const CategoryTab({
    super.key,
    required this.controller,
    required this.categoryScrollController,
    required this.productGridController,
    required this.viewModel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final categories = viewModel.orderedCategories;

    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Material(
              type: MaterialType.transparency,
              child: IconButton(
                onPressed: () async {
                  await controller.showFilterPopup();
                },
                icon: const Icon(Icons.filter_list, color: AppColors.sbBlue),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ScrollConfiguration(
                behavior: const _NoGlowScrollBehavior(),
                child: ListView.separated(
                  controller: categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final name = categories[index];
                    final active = state.activeCategory == name;
                    return InkWell(
                      onTap: () => controller.onCategoryTap(
                        index: index,
                        name: name,
                        categoryScrollController: categoryScrollController,
                        productGridController: productGridController,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: active ? AppColors.sbBlue : null,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            width: 28,
                            height: 3,
                            margin: EdgeInsets.only(top: active ? 2 : 0),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.sbBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContentArea extends ConsumerWidget {
  final TransactionPosController controller;
  final ScrollController productGridController;

  const ContentArea({
    super.key,
    required this.controller,
    required this.productGridController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve viewmodel/state for decision logic.
    // final state = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);
    final combined = viewModel.combinedContent;

    // Pastikan ContentArea selalu mengembalikan widget yang dapat discroll sehingga RefreshIndicator
    // dapat bekerja dengan andal. Gunakan ListView sebagai fallback untuk state loading/empty.
    if (combined.isLoadingCombined) {
      return _ContentLoading(productGridController: productGridController);
    }

    if (combined.items.isEmpty) {
      return _ContentEmpty(productGridController: productGridController);
    }

    return _ContentData(
      controller: controller,
      productGridController: productGridController,
    );
  }
}

class _ContentLoading extends StatelessWidget {
  final ScrollController productGridController;

  const _ContentLoading({required this.productGridController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: productGridController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 240,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.sbBlue),
          ),
        )
      ],
    );
  }
}

class _ContentEmpty extends StatelessWidget {
  final ScrollController productGridController;

  const _ContentEmpty({required this.productGridController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: productGridController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 240,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 56,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'Produk tidak ditemukan',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
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
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);
    final combined = viewModel.combinedContent;

    if (combined.items.isEmpty) {
      return _ContentEmpty(productGridController: productGridController);
    }

    return GridView.builder(
      controller: productGridController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: combined.items.length,
      itemBuilder: (context, index) {
        final item = combined.items[index];
        if (item.isPacket) {
          final pkt = item.packet!;
          return PacketCard(
            packet: pkt,
            onTap: () => controller.showPacketSelection(
              packet: pkt,
              products: viewModel.cachedProducts,
            ),
          );
        } else {
          final product = item.product!;
          return ProductCard(
            product: product,
            onTap: () => unawaited(
              controller.onProductTapSmart(product: product),
            ),
          );
        }
      },
    );
  }
}
