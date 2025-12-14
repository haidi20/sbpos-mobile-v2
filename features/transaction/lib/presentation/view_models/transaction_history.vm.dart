import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';

class TransactionHistoryViewModel
    extends StateNotifier<TransactionHistoryState> {
  TransactionHistoryViewModel(
    this._getTransactions,
  ) : super(TransactionHistoryState()) {
    // load offline data on init
    Future.microtask(() => onRefresh());
  }

  final GetTransactionsUsecase _getTransactions;
  final _logger = Logger('TransactionHistoryViewModel');

  /// Getter yang mengembalikan daftar transaksi yang tersimpan secara offline
  /// (diambil dari state).
  List<TransactionEntity> get getTransactions => state.transactions;

  /// Setter untuk query pencarian; mempengaruhi `filteredTransactions`.
  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  /// Set selected date filter (use null to clear)
  Future<void> setSelectedDate(DateTime? date) async {
    // set selected date in state immediately
    if (date == null) {
      state = state.copyWith(selectedDate: null);
    } else {
      final sel = DateTime(date.year, date.month, date.day);
      state = state.copyWith(selectedDate: sel);
    }

    // reload data using GetTransactionsUsecase with date filter
    try {
      await onRefresh();
    } catch (e, st) {
      _logger.severe('Failed to onRefresh transactions', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> onRefresh() async {
    try {
      state = state.copyWith(isLoading: true);
      final q = QueryGetTransactions(
        date: state.selectedDate,
        search: state.searchQuery,
      );
      final res = await _getTransactions.call(
        query: q,
        isOffline: true,
      );
      res.fold((f) {
        _logger.info('Load transactions (offline) failed: $f');
        state = state.copyWith(isLoading: false, error: f.toString());
      }, (list) {
        state = state.copyWith(isLoading: false, transactions: list);
      });
    } catch (e, st) {
      _logger.severe('Failed to load transactions (offline)', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
