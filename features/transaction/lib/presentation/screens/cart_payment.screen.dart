import 'package:core/core.dart';
import 'package:transaction/presentation/widgets/cart_payment.widget.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/cart_payment.controller.dart';

class CartPaymentScreen extends ConsumerStatefulWidget {
  final ScrollController? outerScrollController;
  const CartPaymentScreen({super.key, this.outerScrollController});

  @override
  ConsumerState<CartPaymentScreen> createState() => _CartPaymentScreenState();
}

class _CartPaymentScreenState extends ConsumerState<CartPaymentScreen> {
  late final ScrollController _scrollController;
  late final CartPaymentController _controller;
  late final bool _ownsScrollController;

  @override
  void initState() {
    super.initState();
    if (widget.outerScrollController != null) {
      _scrollController = widget.outerScrollController!;
      _ownsScrollController = false;
    } else {
      _scrollController = ScrollController();
      _ownsScrollController = true;
    }
    _controller = CartPaymentController(ref, context);
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

    // Listen for external changes to the transaction state and synchronize
    // the controller's `cashController`. `ref.listen` must be called from
    // the widget build method (Consumer context), so we register the
    // listener here and delegate logic to the controller.
    ref.listen<TransactionPosState>(transactionPosViewModelProvider,
        (previous, next) => _controller.syncFromState(previous, next));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OrderTypeSelector(
                orderTypes: viewModel.getOrderTypeItems(),
                onChanged: (id) => viewModel.setOrderTypeById(id),
              ),
              const SizedBox(height: 12),
              if (stateTransaction.orderType == EOrderType.online)
                OjolProviderSelector(
                  value: stateTransaction.ojolProvider,
                  onChanged: (v) => viewModel.setOjolProvider(v),
                  vm: viewModel,
                ),
              const SizedBox(height: 12),
              TableNumberSection(
                orderType: stateTransaction.orderType,
                useTableNumber: stateTransaction.useTableNumber,
                onUseTableNumberChanged: (v) => viewModel.setUseTableNumber(v),
                tableNumberController: _controller.tableNumberController,
              ),
              const SizedBox(height: 12),
              PaymentMethodSelector(
                value: stateTransaction.paymentMethod,
                onChanged: (v) => viewModel.setPaymentMethod(v),
                methods: viewModel.paymentMethods,
              ),
              const SizedBox(height: 12),
              PaymentDetails(
                cartDetails: stateTransaction.details,
                cashReceived: stateTransaction.cashReceived,
                paymentMethod: stateTransaction.paymentMethod,
                controller: _controller,
                cashController: _controller.cashController,
                computeCartTotal: () => viewModel.getCartTotalValue,
                computeGrandTotal: () => viewModel.getGrandTotalValue,
                computeChange: () => viewModel.getChangeValue,
                suggestQuickCash: (total) => viewModel.suggestQuickCash(total),
              ),
              const SizedBox(height: 12),
              FooterSummary(
                details: stateTransaction.details,
                isPaid: stateTransaction.isPaid,
                onIsPaidChanged: (v) => viewModel.setIsPaid(v),
                onProcess: () => _controller.onProcess(),
                computeCartTotal: () => viewModel.getCartTotalValue,
                computeTax: () => viewModel.getTaxValue,
                computeGrandTotal: () => viewModel.getGrandTotalValue,
              ),
              if (stateTransaction.showErrorSnackbar) const SizedBox(height: 8),
              if (stateTransaction.showErrorSnackbar) const ErrorSnackbar(),
            ],
          ),
        ),
      ),
    );
  }
}
