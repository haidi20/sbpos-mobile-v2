import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/widgets/cart_method_payment.widget.dart';
import 'package:transaction/presentation/controllers/cart_method_payment.controller.dart';

class CartMethodPaymentScreen extends ConsumerStatefulWidget {
  const CartMethodPaymentScreen({super.key});

  @override
  ConsumerState<CartMethodPaymentScreen> createState() =>
      _CartMethodPaymentScreenState();
}

class _CartMethodPaymentScreenState
    extends ConsumerState<CartMethodPaymentScreen> {
  late final ScrollController _scrollController;
  late final CartMethodPaymentController _controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = CartMethodPaymentController(ref, context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateTransaction = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

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
              ),
              const SizedBox(height: 12),
              PaymentDetails(
                cartDetails: stateTransaction.details,
                cashReceived: stateTransaction.cashReceived,
                paymentMethod: stateTransaction.paymentMethod,
                onCashChanged: (v) => viewModel.setCashReceived(v),
                computeCartTotal: () => viewModel.getCartTotalValue,
                computeGrandTotal: () => viewModel.getGrandTotalValue,
                computeChange: () => viewModel.getChangeValue,
                suggestQuickCash: (total) => viewModel.suggestQuickCash(total),
              ),
              const SizedBox(height: 12),
              FooterSummary(
                details: stateTransaction.details,
                viewMode: stateTransaction.viewMode,
                isPaid: stateTransaction.isPaid,
                onIsPaidChanged: (v) => viewModel.setIsPaid(v),
                onProcess: () => _controller.onProcess(),
                onToggleView: () => _controller.onToggleView(),
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
