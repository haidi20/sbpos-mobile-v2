import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions_offline.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';

class TransactionHistoryViewModel
    extends StateNotifier<TransactionHistoryState> {
  TransactionHistoryViewModel(
    GetTransactionsUsecase _,
    this._getTransactionsOffline,
  ) : super(TransactionHistoryState()) {
    // load offline data on init
    Future.microtask(() => refresh());
  }

  final GetTransactionsOffline _getTransactionsOffline;
  final _logger = Logger('TransactionHistoryViewModel');

  /// Getter yang mengembalikan daftar transaksi yang tersimpan secara offline
  /// (diambil dari state).
  List<TransactionEntity> get getTransactionsOffline => state.transactions;

  /// Mengembalikan daftar transaksi yang sudah difilter berdasarkan
  /// `state.searchQuery` (case-insensitive) dan berdasarkan sequence/notes.
  List<TransactionEntity> get getFilteredTransactions {
    final query = (state.searchQuery ?? '').toLowerCase();
    // first apply date filter if present
    final DateTime? sel = state.selectedDate;
    List<TransactionEntity> list = state.transactions;
    if (sel != null) {
      list = list.where((tx) {
        final d = tx.date;
        return d.year == sel.year && d.month == sel.month && d.day == sel.day;
      }).toList();
    }

    if (query.isEmpty) return list;

    return list.where((tx) {
      final seq = tx.sequenceNumber.toString();
      final notes = (tx.notes ?? '').toLowerCase();
      return seq.contains(query) || notes.contains(query);
    }).toList();
  }

  /// Setter untuk query pencarian; mempengaruhi `filteredTransactions`.
  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  /// Set selected date filter (use null to clear)
  void setSelectedDate(DateTime? date) {
    if (date == null) {
      state = state.copyWith(selectedDate: null);
    } else {
      final sel = DateTime(date.year, date.month, date.day);
      state = state.copyWith(selectedDate: sel);
    }
  }

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
