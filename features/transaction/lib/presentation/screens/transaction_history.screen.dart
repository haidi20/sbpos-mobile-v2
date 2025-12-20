import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';
import 'package:transaction/presentation/controllers/transaction_history.controller.dart';
import 'package:transaction/presentation/widgets/transaction_history_screen.widget.dart';
import 'package:transaction/presentation/widgets/transaction_history_tabtime.widget.dart';

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
    // controller not required here; use ViewModel for actions
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
              onRefresh: () => viewModel.onRefresh(),
              isLoading: state.isLoading,
            ),

            // date tabs
            TransactionHistoryTabtime(
              daysToShow: 7,
              selectedDate: state.selectedDate,
              onDateSelected: (d) => viewModel.setSelectedDate(d),
            ),

            // --- LIST with pull-to-refresh ---
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => viewModel.onRefresh(),
                color: AppColors.sbBlue,
                displacement: 32,
                child: TransactionHistoryList(
                  transactions: filteredTransactions,
                  isLoading: state.isLoading,
                  onTap: (tx) async {
                    await _controller.showTransactionActions(context, ref, tx);
                  },
                  onDateShift: (shiftDays) =>
                      viewModel.shiftSelectedDate(shiftDays),
                  onLongPress: (tx) async {
                    //
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
