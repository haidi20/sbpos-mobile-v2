import 'package:core/core.dart';
import 'package:transaction/presentation/widgets/cart_payment.widget.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/cart_payment.controller.dart';

class CartPaymentScreen extends ConsumerStatefulWidget {
  const CartPaymentScreen({super.key});

  @override
  ConsumerState<CartPaymentScreen> createState() => _CartPaymentScreenState();
}

class _CartPaymentScreenState extends ConsumerState<CartPaymentScreen> {
  late final ScrollController _scrollController;
  late final CartPaymentController _controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = CartPaymentController(ref, context);
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
                onCashChanged: (v) => viewModel.setCashReceived(v),
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
