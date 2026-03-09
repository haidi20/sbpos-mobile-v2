import 'package:core/core.dart';
import 'package:transaction/presentation/controllers/transaction_history_tabtime.logic.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';

/// Hasil dari persiapan daftar tanggal: daftar tanggal dan indeks awal.
class DatesInit {
  final int initialIndex;
  final List<DateTime> dates;

  DatesInit(
    this.dates,
    this.initialIndex,
  );
}

/// Controller untuk TransactionHistoryTabtime.
///
/// Mengelola logika UI yang membutuhkan `BuildContext` atau kontrol lokal
/// seperti `TextEditingController` (mis. input pencarian, pemilih tanggal).
typedef TransactionHistoryStateReader = TransactionHistoryState Function(
  WidgetRef ref,
);

typedef TransactionHistoryDateSetter = Future<void> Function(
  WidgetRef ref,
  DateTime? date,
);

typedef TransactionHistoryStateListener = VoidCallback Function(
  WidgetRef ref,
  void Function(TransactionHistoryState? previous, TransactionHistoryState next)
      listener,
);

class TransactionHistoryTabtimeController {
  TransactionHistoryTabtimeController({
    TransactionHistoryStateReader? readState,
    TransactionHistoryDateSetter? setSelectedDate,
    TransactionHistoryStateListener? listenState,
  })  : _readState = readState ?? _defaultReadState,
        _setSelectedDate = setSelectedDate ?? _defaultSetSelectedDate,
        _listenState = listenState ?? _defaultListenState;

  final TextEditingController searchController = TextEditingController();
  final TransactionHistoryStateReader _readState;
  final TransactionHistoryDateSetter _setSelectedDate;
  final TransactionHistoryStateListener _listenState;
  VoidCallback? _cancelStateListener;

  /// Bersihkan resource internal controller.
  void dispose() {
    detachTabController();
    searchController.dispose();
  }

  /// Tampilkan pemilih tanggal dan set tanggal yang dipilih ke ViewModel.
  Future<void> showDatePickerAndSelect(
    BuildContext context,
    WidgetRef ref, {
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final init = initialDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      await _setSelectedDate(
        ref,
        DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  /// Kembalikan label tampil untuk sebuah tanggal.
  ///
  /// Contoh output: "Hari ini", "Kemarin", atau format `dd/MM/yy`.
  String labelForDate(DateTime d) {
    return TransactionHistoryTabtimeLogic.labelForDate(d);
  }

  /// Pilih tanggal yang diberikan pada ViewModel.
  ///
  /// Menormalkan waktu menjadi hanya komponen tanggal (year, month, day).
  Future<void> selectDate(WidgetRef ref, DateTime d) async {
    final sel = DateTime(d.year, d.month, d.day);
    await _setSelectedDate(ref, sel);
  }

  TabController? _tabController;
  List<DateTime>? _attachedDates;
  int _lastIndex = -1;

  /// Pasang sebuah [TabController] dan hubungkan listener-nya serta listener
  /// ke ViewModel sehingga controller menangani sinkronisasi pilihan tanggal.
  ///
  /// Callback `onDateSelected` dipanggil saat pengguna memilih tab, sedangkan
  /// `onSwipeLeft` / `onSwipeRight` dipanggil ketika terjadi geser antar-tab.
  void attachTabController(
    TabController tabController,
    WidgetRef ref,
    List<DateTime> dates, {
    ValueChanged<DateTime>? onDateSelected,
    ValueChanged<DateTime>? onSwipeLeft,
    ValueChanged<DateTime>? onSwipeRight,
  }) {
    // lepaskan (detach) controller sebelumnya jika ada
    if (_tabController != null && _tabController != tabController) {
      try {
        _tabController!.removeListener(_tabListener);
      } catch (_) {
        // abaikan jika gagal melepas listener
      }
    }
    _cancelStateListener?.call();
    _cancelStateListener = null;

    _tabController = tabController;
    _attachedDates = dates;
    _lastIndex = tabController.index;

    tabController.addListener(_tabListener = () {
      if (tabController.indexIsChanging) {
        return;
      }
      final idx = tabController.index;
      final change = TransactionHistoryTabtimeLogic.selectionForIndex(
        idx: idx,
        lastIndex: _lastIndex,
        dates: _attachedDates,
      );
      if (change == null) {
        return;
      }
      final d = change.date;
      // perbarui ViewModel dengan tanggal yang dipilih
      selectDate(ref, d);
      onDateSelected?.call(d);

      // deteksi arah geser antar-tab dan panggil callback yang sesuai
      if (change.direction == TabSwipeDirection.left) {
        onSwipeLeft?.call(d);
      } else {
        onSwipeRight?.call(d);
      }
      _lastIndex = idx;
    });

    // Dengarkan perubahan `selectedDate` di ViewModel dan animasikan TabController
    // agar posisi tab mengikuti tanggal yang diset dari luar.
    _cancelStateListener = _listenState(ref, (previous, next) {
      final sel = next.selectedDate;
      if (sel == null || _attachedDates == null || _tabController == null) {
        return;
      }
      final idx = findIndexForDate(_attachedDates!, sel);
      if (idx != -1 && _tabController!.index != idx) {
        try {
          _tabController!
              .animateTo(idx, duration: const Duration(milliseconds: 220));
        } catch (_) {
          // abaikan jika animasi gagal
        }
      }
    });
  }

  late VoidCallback _tabListener;

  /// Lepaskan [TabController] yang terpasang sebelumnya, jika ada.
  /// Members internal yang terkait akan direset.
  void detachTabController() {
    _cancelStateListener?.call();
    _cancelStateListener = null;
    if (_tabController != null) {
      try {
        _tabController!.removeListener(_tabListener);
      } catch (_) {}
      _tabController = null;
      _attachedDates = null;
      _lastIndex = -1;
    }
  }

  /// Hasilkan daftar tanggal berurutan dari yang terlama ke terbaru.
  ///
  /// Basis tanggal diambil dari ViewModel jika tersedia, jika tidak gunakan
  /// `DateTime.now()`.
  List<DateTime> generateDateList(WidgetRef ref, int daysToShow) {
    return TransactionHistoryTabtimeLogic.generateDateList(
      daysToShow,
      selectedDate: _readState(ref).selectedDate,
    );
  }

  /// Cari indeks tanggal `d` di dalam daftar `dates`.
  ///
  /// Mengembalikan `-1` apabila tidak ditemukan.
  int findIndexForDate(List<DateTime> dates, DateTime d) {
    return TransactionHistoryTabtimeLogic.findIndexForDate(dates, d);
  }

  /// Tentukan tanggal awal yang dipilih dengan prioritas: ViewModel -> nilai
  /// `provided` -> elemen terakhir dari daftar.
  DateTime resolveInitialSelected(
      WidgetRef ref, DateTime? provided, List<DateTime> dates) {
    return TransactionHistoryTabtimeLogic.resolveInitialSelected(
      selectedDate: _readState(ref).selectedDate,
      provided: provided,
      dates: dates,
    );
  }

  /// Siapkan daftar tanggal dan indeks awal untuk TabController.
  ///
  /// Mengembalikan `DatesInit` yang berisi `dates` (oldest->newest) dan
  /// `initialIndex` yang cocok untuk digunakan sebagai `initialIndex` pada
  /// `TabController`.
  DatesInit prepareDates(WidgetRef ref, int daysToShow,
      {DateTime? providedSelected}) {
    final prepared = TransactionHistoryTabtimeLogic.prepareDates(
      daysToShow,
      selectedDate: _readState(ref).selectedDate,
      providedSelected: providedSelected,
    );
    return DatesInit(prepared.dates, prepared.initialIndex);
  }

  /// Tangani ketukan (tap) pada tab dengan indeks `idx`.
  ///
  /// Memvalidasi indeks, memperbarui ViewModel dengan tanggal yang
  /// dipilih, memanggil `onDateSelected` callback bila ada, dan
  /// melakukan animasi ke tab tersebut.
  void handleTapIndex(WidgetRef ref, int idx,
      {ValueChanged<DateTime>? onDateSelected}) {
    if (_tabController == null) {
      return;
    }
    final d = TransactionHistoryTabtimeLogic.dateAtIndex(_attachedDates, idx);
    if (d == null) {
      return;
    }
    // perbarui ViewModel
    selectDate(ref, d);
    // panggil callback
    onDateSelected?.call(d);
    // animasikan tab
    try {
      _tabController!.animateTo(idx);
    } catch (_) {
      // abaikan jika animasi gagal
    }
    _lastIndex = idx;
  }

  /// Cek apakah tanggal `d` merupakan tanggal yang sedang dipilih.
  ///
  /// Membandingkan tanggal berdasarkan year/month/day; menggunakan pilihan dari
  /// ViewModel, jika tidak tersedia gunakan `provided` sebagai fallback.
  bool isSelected(WidgetRef ref, DateTime? provided, DateTime d) {
    return TransactionHistoryTabtimeLogic.isSelected(
      selectedDate: _readState(ref).selectedDate,
      provided: provided,
      date: d,
    );
  }
}

TransactionHistoryState _defaultReadState(WidgetRef _) {
  return TransactionHistoryState();
}

Future<void> _defaultSetSelectedDate(WidgetRef _, DateTime? __) async {}

VoidCallback _defaultListenState(
  WidgetRef _,
  void Function(TransactionHistoryState? previous, TransactionHistoryState next)
      __,
) {
  return () {};
}
