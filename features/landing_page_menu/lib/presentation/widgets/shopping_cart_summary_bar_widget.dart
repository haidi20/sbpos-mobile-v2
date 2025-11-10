import 'package:core/core.dart';
import 'package:landing_page_menu/landing_page_menu.dart';
// import 'package:landing_page_menu/presentation/controllers/landing_page_menu_controller.dart';

class ShoppingCartSummaryBarWidget extends ConsumerStatefulWidget {
  const ShoppingCartSummaryBarWidget({
    super.key,
  });

  @override
  ConsumerState<ShoppingCartSummaryBarWidget> createState() =>
      _ShoppingCartSummaryBarWidgetState();
}

class _ShoppingCartSummaryBarWidgetState
    extends ConsumerState<ShoppingCartSummaryBarWidget> {
  // late LandingPageMenuController _controller;
  // static final Logger _logger = Logger('ShoppingCartSummaryBarWidget');

  @override
  void initState() {
    super.initState();
    // _controller = LandingPageMenuController(ref, context);
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landingPageMenuViewModelProvider);
    final viewModel = ref.read(landingPageMenuViewModelProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        // ✅ HILANGKAN SHADOW JIKA TIDAK DIBUTUHKAN
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4), // Shadow ke bawah
        //   ),
        // ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: viewModel.onCheckout,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppSetting.primaryColor, // Bright pink
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icon & Total Info
                Expanded(
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          const Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          if (state.itemSelectedCount > 0)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  state.itemSelectedCount.toString(),
                                  style: const TextStyle(
                                    color: AppSetting.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            viewModel.totalPriceReadable,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // CHECK OUT Button
                Text(
                  'CHECK OUT (${state.itemSelectedCount})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
