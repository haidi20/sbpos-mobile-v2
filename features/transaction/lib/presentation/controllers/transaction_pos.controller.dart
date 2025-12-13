import 'package:core/core.dart';
import 'package:transaction/presentation/sheets/cart_bottom.sheet.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

class TransactionPosController {
  final WidgetRef ref;
  final BuildContext context;
  final TransactionPosViewModel viewModel;
  final TextEditingController searchController = TextEditingController();

  TransactionPosController(this.ref, this.context)
      : viewModel = ref.read(transactionPosViewModelProvider.notifier);

  void onShowCartSheet() {
    viewModel.setTypeChart(ETypeChart.main);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }
}
