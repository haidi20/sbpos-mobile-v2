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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OrderTypeSelector(
            orderTypes: _controller.getOrderTypeItems(),
            onChanged: (id) => _controller.selectOrderTypeById(id),
          ),
          const SizedBox(height: 12),
          if (stateTransaction.orderType == EOrderType.online)
            OjolProviderSelector(
              value: stateTransaction.ojolProvider,
              onChanged: (v) => viewModel.setOjolProvider(v),
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
          ),
          const SizedBox(height: 12),
          FooterSummary(
            details: stateTransaction.details,
            viewMode: stateTransaction.viewMode,
            onProcess: () => _controller.onProcess(),
            onToggleView: () => _controller.onToggleView(),
          ),
          if (stateTransaction.showErrorSnackbar) const SizedBox(height: 8),
          if (stateTransaction.showErrorSnackbar) const ErrorSnackbar(),
        ],
      ),
    );
  }
}
