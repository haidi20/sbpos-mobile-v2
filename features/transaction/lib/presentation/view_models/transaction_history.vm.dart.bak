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
  Timer? _searchDebounce;

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

  /// Pencarian berbasis event dengan debounce; memicu kueri ke DB lokal.
  void onSearchChanged(
    String q, {
    Duration debounce = const Duration(milliseconds: 500),
  }) {
    // update query immediately for UI reflect
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
