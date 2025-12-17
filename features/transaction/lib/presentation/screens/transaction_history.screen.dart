import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';
import 'package:transaction/presentation/widgets/transaction_history_screen.widget.dart';
import 'package:transaction/presentation/widgets/transaction_history_tabtime.widget.dart';
import 'package:transaction/presentation/controllers/transaction_history.controller.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  late final TransactionHistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransactionHistoryController();
    Future.microtask(() =>
        ref.read(transactionHistoryViewModelProvider.notifier).onRefresh());
  }

  @override
  Widget build(BuildContext context) {
    final TransactionHistoryViewModel viewModel =
        ref.watch(transactionHistoryViewModelProvider.notifier);
    final state = ref.watch(transactionHistoryViewModelProvider);
    final List<TransactionEntity> filteredTransactions =
        viewModel.getTransactions;

    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: Column(
          children: [
            // extracted header widget
            TransactionHistoryHeader(
              onSearch: viewModel.setSearchQuery,
              onDateSelected: (d) => viewModel.setSelectedDate(d),
            ),

            // date tabs
            TransactionHistoryTabtime(
              daysToShow: 7,
              onDateSelected: (d) => viewModel.setSelectedDate(d),
            ),

            // --- LIST ---
            Expanded(
              child: TransactionHistoryList(
                transactions: filteredTransactions,
                isLoading: state.isLoading,
                onTap: (tx) => _controller.onShowTransactionDetail(context, tx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
