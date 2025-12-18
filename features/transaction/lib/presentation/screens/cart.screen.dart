import 'package:core/core.dart';
import 'package:transaction/presentation/widgets/cart_screen.widget.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';

class CartScreen extends ConsumerStatefulWidget {
  final bool readOnly;
  final ScrollController? outerScrollController;

  const CartScreen(
      {super.key, this.readOnly = false, this.outerScrollController});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late final CartScreenController _controller;
  late final ScrollController _scrollController;
  late final bool _ownsScrollController;

  @override
  void initState() {
    super.initState();
    _ownsScrollController = widget.outerScrollController == null;
    _scrollController = widget.outerScrollController ?? ScrollController();
    _controller = CartScreenController(ref, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsScrollController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateTransaction = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CartHeader(
          viewModel: viewModel,
          stateTransaction: stateTransaction,
          onClearCart: _controller.onClearCart,
        ),
        CustomerCard(
          viewModel: viewModel,
          state: stateTransaction,
        ),
        const SizedBox(height: 24),
        // The scrollable content must have bounded height. Wrap the
        // ListView in Expanded so it fills the remaining space inside
        // the sheet and gets proper constraints.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              // This ListView is the scrollable area when embedded in the
              // sheet: allow normal scrolling so the sheet's
              // scrollController can coordinate drag/scroll.
              physics: const ClampingScrollPhysics(),
              children: [
                OrderListWidget(
                  viewModel: viewModel,
                  stateTransaction: stateTransaction,
                  controller: _controller,
                  orderNoteController: _controller.orderNoteController,
                  readOnly: widget.readOnly,
                ),
                SummaryBottomWidget(
                  viewModel: viewModel,
                  controller: _controller,
                  readOnly: widget.readOnly,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
