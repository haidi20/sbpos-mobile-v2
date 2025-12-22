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

  /// Daftar transaksi untuk tab "Main" (status pending)
  List<TransactionEntity> get mainTransactions => state.transactions.toList();

  /// Daftar transaksi untuk tab "Proses" (status proses)
  List<TransactionEntity> get prosesTransactions => state.transactions
      .where((t) => t.status == TransactionStatus.proses)
      .toList();

  /// Daftar transaksi untuk tab "Selesai" (status lunas)
  List<TransactionEntity> get selesaiTransactions => state.transactions
      .where((t) => t.status == TransactionStatus.lunas)
      .toList();

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

      // _logger.info(
      //     'tanggal filter: ${state.selectedDate}, search: ${state.searchQuery}');

      final res = await _getTransactions.call(
        query: q,
        isOffline: true,
      );

      res.fold((f) {
        _logger.info('Load transactions (offline) failed: $f');
        state = state.copyWith(isLoading: false, error: f.toString());
      }, (list) {
        // _logger.info('jumlah data: ${list.length}');
        state = state.copyWith(isLoading: false, transactions: list);
      });
    } catch (e, st) {
      _logger.severe('Failed to load transactions (offline)', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Shift the currently selected date by [shiftDays]. If no date is selected,
  /// shift relative to today. This delegates to `setSelectedDate` which will
  /// trigger a refresh.
  Future<void> shiftSelectedDate(int shiftDays) async {
    final current = state.selectedDate ?? DateTime.now();
    final newDate = current.add(Duration(days: shiftDays));
    await setSelectedDate(newDate);
  }

  /// Generate a list of consecutive dates ending today with length [daysToShow].
  /// The list is ordered from older -> newer (start .. today).
  List<DateTime> generateDateList(int daysToShow) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: daysToShow - 1));
    return List.generate(daysToShow, (i) => start.add(Duration(days: i)));
  }
}
