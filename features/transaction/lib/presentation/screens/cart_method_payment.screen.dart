import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/controllers/cart_bottom_sheet.controller.dart';
import 'package:transaction/presentation/widgets/cart_method_payment.widget.dart';

class CartMethodPaymentScreen extends ConsumerStatefulWidget {
  const CartMethodPaymentScreen({super.key});

  @override
  ConsumerState<CartMethodPaymentScreen> createState() =>
      _CartMethodPaymentScreenState();
}

class _CartMethodPaymentScreenState
    extends ConsumerState<CartMethodPaymentScreen> {
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

    // Return the inner column only — this widget is intended to be
    // included inside the bottom sheet `cart_bottom.sheet.dart`.
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OrderTypeSelector(
              onChanged: (v) => viewModel.setOrderType(v),
              value: stateTransaction.orderType),
          const SizedBox(height: 12),
          if (stateTransaction.orderType == 'online')
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
            paymentMethod: stateTransaction.paymentMethod,
            cashReceived: stateTransaction.cashReceived,
            onCashChanged: (v) => viewModel.setCashReceived(v),
            cartDetails: stateTransaction.details,
          ),
          const SizedBox(height: 12),
          FooterSummary(
            details: stateTransaction.details,
            viewMode: stateTransaction.viewMode,
            onToggleView: () => viewModel.setViewMode(
                stateTransaction.viewMode == 'cart' ? 'checkout' : 'cart'),
            onProcess: () {
              if (stateTransaction.orderType == 'online' &&
                  (stateTransaction.ojolProvider.isEmpty)) {
                viewModel.setShowErrorSnackbar(true);
                Future.delayed(const Duration(seconds: 3),
                    () => viewModel.setShowErrorSnackbar(false));
                return;
              }
              // Hook point: call viewModel to process payment if available
            },
          ),
          if (stateTransaction.showErrorSnackbar) const SizedBox(height: 8),
          if (stateTransaction.showErrorSnackbar) const ErrorSnackbar(),
        ],
      ),
    );
  }
}
