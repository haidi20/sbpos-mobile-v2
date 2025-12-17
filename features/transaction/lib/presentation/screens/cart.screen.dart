import 'package:core/core.dart';
import 'package:transaction/presentation/widgets/cart_screen.widget.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';

class CartScreen extends ConsumerStatefulWidget {
  final bool readOnly;

  const CartScreen({super.key, this.readOnly = false});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late final CartScreenController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = CartScreenController(ref, context);
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
        // Bagian ini saja yang scroll saat data banyak
        // Ensure the ListView has a bounded height when included inside
        // a bottom sheet / layout with unbounded constraints.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              controller: _scrollController,
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
