import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/widgets/cart_bottom_sheet.widget.dart';
import 'package:transaction/presentation/controllers/cart_bottom_sheet.controller.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late final CartBottomSheetController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = CartBottomSheetController(ref, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateTransaction = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildHeader(
          viewModel: viewModel,
          stateTransaction: stateTransaction,
          onClearCart: _controller.onClearCart,
        ),
        buildCustomerCard(
          context: context,
          viewModel: viewModel,
          state: stateTransaction,
        ),
        const SizedBox(height: 24),
        // Bagian ini saja yang scroll saat data banyak
        // Ensure the ListView has a bounded height when included inside
        // a bottom sheet / layout with unbounded constraints.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Limit list height to a reasonable portion of the screen
              // so it gets a bounded height for its viewport.
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              children: [
                buildOrderList(
                  viewModel: viewModel,
                  stateTransaction: stateTransaction,
                  controller: _controller,
                  orderNoteController: _controller.orderNoteController,
                ),
                buildSummaryBottom(
                  context: context,
                  viewModel: viewModel,
                  controller: _controller,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
