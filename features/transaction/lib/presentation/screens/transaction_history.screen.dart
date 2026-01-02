// ignore_for_file: prefer_const_constructors
import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';
import 'package:transaction/presentation/widgets/transaction_history_screen.widget.dart';
import 'package:transaction/presentation/controllers/transaction_history.controller.dart';
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
  late final TransactionHistoryViewModel _viewModel;

  // Note: state will be read reactively in build via `ref.watch`

  @override
  void initState() {
    super.initState();
    _controller = TransactionHistoryController();

    // setup viewmodel once per State lifecycle
    _viewModel = ref.read(transactionHistoryViewModelProvider.notifier);

    // initial refresh
    Future.microtask(() => _viewModel.onRefresh());
  }

  @override
  Widget build(BuildContext context) {
    // read state reactively here
    final TransactionHistoryState state =
        ref.watch(transactionHistoryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.sbBg,
        elevation: 0,
      ),
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: Column(
          children: [
            // extracted header widget
            TransactionHistoryHeader(
              onSearch: _viewModel.onSearchChanged,
              onDateSelected: (_) =>
                  _controller.showDatePickerAndSelect(context, ref),
              onRefresh: () => _viewModel.onRefresh(),
              isLoading: state.isLoading,
            ),

            // date tabs + body
            Expanded(
              child: TransactionHistoryTabtime(
                daysToShow: 7,
                selectedDate: state.selectedDate,
                onDateSelected: (d) => _viewModel.setSelectedDate(d),
                bodyBuilder: (ctx, ref, date) {
                  final st = ref.watch(transactionHistoryViewModelProvider);
                  return RefreshIndicator(
                    onRefresh: () => _viewModel.onRefresh(),
                    color: AppColors.sbBlue,
                    displacement: 32,
                    child: TransactionHistoryList(
                      transactions: st.transactions,
                      isLoading: st.isLoading,
                      onTap: (tx) async {
                        await _controller.showTransactionActions(
                          context,
                          ref,
                          tx,
                        );
                      },
                      onDateShift: (shiftDays) =>
                          _viewModel.shiftSelectedDate(shiftDays),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
