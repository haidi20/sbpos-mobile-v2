import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/usecases/get_not_paid_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';

class TransactionHistoryViewModel
    extends StateNotifier<TransactionHistoryState> {
  TransactionHistoryViewModel(
    GetTransactionsUsecase getTransactions, [
    GetNotPaidTransactions? getNotPaidTransactions,
  ]
  )  : _getNotPaidTransactions = getNotPaidTransactions,
        _getTransactions = getTransactions,
        super(TransactionHistoryState()) {
    // muat offline data on init
    Future.microtask(() => onRefresh());
  }

  final GetTransactionsUsecase _getTransactions;
  final GetNotPaidTransactions? _getNotPaidTransactions;
  final _logger = Logger('TransactionHistoryViewModel');
  Timer? _searchDebounce;

  /// Getter yang mengembalikan daftar transaksi yang tersimpan secara offline
  /// (diambil dari state).
  List<TransactionEntity> get getTransactions => state.transactions;
  List<TransactionEntity> get getNotPaid => state.notPaidTransactions;

  bool get isShowingNotPaid => state.mode == TransactionHistoryMode.notPaid;

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

  List<TransactionEntity> get visibleTransactions {
    final source = isShowingNotPaid ? state.notPaidTransactions : state.transactions;
    final query = (state.searchQuery ?? '').toLowerCase();
    final selectedDate = state.selectedDate;

    return source.where((transaction) {
      final matchesQuery = query.isEmpty ||
          (transaction.notes ?? '').toLowerCase().contains(query) ||
          transaction.sequenceNumber.toString().contains(query) ||
          (transaction.customerSelected?.name ?? '')
              .toLowerCase()
              .contains(query);
      if (!matchesQuery) return false;

      if (selectedDate == null) return true;
      final date = transaction.date;
      return date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
    }).toList();
  }

  /// Pencarian berbasis event dengan debounce; memicu kueri ke DB lokal.
  void onSearchChanged(
    String q, {
    Duration debounce = const Duration(milliseconds: 500),
  }) {
    // perbarui query immediately for UI reflect
    state = state.copyWith(searchQuery: q);
    // debounce refresh to avoid excessive DB calls
    _searchDebounce?.cancel();
    _searchDebounce = Timer(debounce, () async {
      try {
        await onRefresh();
      } catch (e, st) {
        _logger.severe('Debounced search failed', e, st);
      }
    });
  }

  /// Atur filter tanggal terpilih (pakai null untuk membersihkan)
  Future<void> setSelectedDate(DateTime? date) async {
    // set selected date in state immediately
    if (date == null) {
      state = state.copyWith(selectedDate: null);
    } else {
      final sel = DateTime(date.year, date.month, date.day);
      state = state.copyWith(selectedDate: sel);
    }

    // remuat data using GetTransactionsUsecase with date filter
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
        state = state.copyWith(isLoading: false, transactions: list);
      });

      if (_getNotPaidTransactions != null) {
        await refreshNotPaidTransactions();
      }
    } catch (e, st) {
      _logger.severe('Failed to load transactions (offline)', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshNotPaidTransactions() async {
    final usecase = _getNotPaidTransactions;
    if (usecase == null) {
      return;
    }

    try {
      state = state.copyWith(isLoadingNotPaid: true);
      final result = await usecase();
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoadingNotPaid: false,
            error: failure.message,
          );
        },
        (transactions) {
          state = state.copyWith(
            isLoadingNotPaid: false,
            notPaidTransactions: transactions,
          );
        },
      );
    } catch (e, st) {
      _logger.severe('Failed to load not paid transactions', e, st);
      state = state.copyWith(
        isLoadingNotPaid: false,
        error: e.toString(),
      );
    }
  }

  Future<void> setMode(TransactionHistoryMode mode) async {
    state = state.copyWith(mode: mode);
    if (mode == TransactionHistoryMode.notPaid &&
        state.notPaidTransactions.isEmpty &&
        _getNotPaidTransactions != null) {
      await refreshNotPaidTransactions();
    }
  }

  /// Geser tanggal terpilih saat ini sebesar [shiftDays]. Jika tidak ada tanggal
  /// terpilih, geser relatif terhadap hari ini. Ini mendelegasikan ke
  /// `setSelectedDate` yang akan memicu refresh.
  Future<void> shiftSelectedDate(int shiftDays) async {
    final current = state.selectedDate ?? DateTime.now();
    final newDate = current.add(Duration(days: shiftDays));
    await setSelectedDate(newDate);
  }

  /// Hasilkan daftar tanggal berturut-turut yang berakhir hari ini dengan panjang
  /// [daysToShow].
  /// Daftar diurutkan dari yang lebih lama ke yang lebih baru (mulai .. hari ini).
  List<DateTime> generateDateList(int daysToShow) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: daysToShow - 1));
    return List.generate(daysToShow, (i) => start.add(Duration(days: i)));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
