import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions_offline.usecase.dart';

class TransactionState {
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? error;

  TransactionState(
      {List<TransactionEntity>? transactions,
      this.isLoading = false,
      this.error})
      : transactions = transactions ?? const [];

  TransactionState copyWith(
      {List<TransactionEntity>? transactions, bool? isLoading, String? error}) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TransactionViewModel extends StateNotifier<TransactionState> {
  final GetTransactionsOffline _getTransactionsOffline;
  final _logger = Logger('TransactionViewModel');

  TransactionViewModel(GetTransactionsUsecase _, this._getTransactionsOffline)
      : super(TransactionState()) {
    // _loadTransactions();
  }

  // _loadTransactions was removed because it's unused; use `refresh()` or
  // call the usecase directly when needed.

  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true);
      final res = await _getTransactionsOffline.call();
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
