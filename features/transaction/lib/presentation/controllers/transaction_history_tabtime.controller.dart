import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';

/// Hasil dari persiapan daftar tanggal: daftar tanggal dan indeks awal.
class DatesInit {
  final List<DateTime> dates;
  final int initialIndex;

  DatesInit(this.dates, this.initialIndex);
}

/// Controller untuk TransactionHistoryTabtime.
///
/// Mengelola logika UI yang membutuhkan `BuildContext` atau kontrol lokal
/// seperti `TextEditingController` (mis. input pencarian, pemilih tanggal).
class TransactionHistoryTabtimeController {
  final TextEditingController searchController = TextEditingController();

  /// Bersihkan resource internal controller.
  void dispose() {
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
      await ref
          .read(transactionHistoryViewModelProvider.notifier)
          .setSelectedDate(DateTime(picked.year, picked.month, picked.day));
    }
  }

  /// Kembalikan label tampil untuk sebuah tanggal.
  ///
  /// Contoh output: "Hari ini", "Kemarin", atau format `dd/MM/yy`.
  String labelForDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return 'Hari ini';
    }
    if (d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day) {
      return 'Kemarin';
    }
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }

  /// Pilih tanggal yang diberikan pada ViewModel.
  ///
  /// Menormalkan waktu menjadi hanya komponen tanggal (year, month, day).
  Future<void> selectDate(WidgetRef ref, DateTime d) async {
    final sel = DateTime(d.year, d.month, d.day);
    await ref
        .read(transactionHistoryViewModelProvider.notifier)
        .setSelectedDate(sel);
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

    _tabController = tabController;
    _attachedDates = dates;
    _lastIndex = tabController.index;

    tabController.addListener(_tabListener = () {
      if (tabController.indexIsChanging) {
        return;
      }
      final idx = tabController.index;
      if (idx < 0 || _attachedDates == null || idx >= _attachedDates!.length) {
        return;
      }
      final d = _attachedDates![idx];
      // perbarui ViewModel dengan tanggal yang dipilih
      selectDate(ref, d);
      onDateSelected?.call(d);

      // deteksi arah geser antar-tab dan panggil callback yang sesuai
      if (idx != _lastIndex) {
        if (idx > _lastIndex) {
          onSwipeLeft?.call(d);
        } else {
          onSwipeRight?.call(d);
        }
        _lastIndex = idx;
      }
    });

    // Dengarkan perubahan `selectedDate` di ViewModel dan animasikan TabController
    // agar posisi tab mengikuti tanggal yang diset dari luar.
    ref.listen<TransactionHistoryState>(transactionHistoryViewModelProvider,
        (previous, next) {
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
    final vmSel = ref.read(transactionHistoryViewModelProvider).selectedDate;
    final base = vmSel ?? DateTime.now();
    final end = DateTime(base.year, base.month, base.day);
    return List.generate(
      daysToShow,
      (i) => end.subtract(
        Duration(days: daysToShow - 1 - i),
      ),
    );
  }

  /// Cari indeks tanggal `d` di dalam daftar `dates`.
  ///
  /// Mengembalikan `-1` apabila tidak ditemukan.
  int findIndexForDate(List<DateTime> dates, DateTime d) {
    return dates.indexWhere(
        (x) => x.year == d.year && x.month == d.month && x.day == d.day);
  }

  /// Tentukan tanggal awal yang dipilih dengan prioritas: ViewModel -> nilai
  /// `provided` -> elemen terakhir dari daftar.
  DateTime resolveInitialSelected(
      WidgetRef ref, DateTime? provided, List<DateTime> dates) {
    final vmSel = ref.read(transactionHistoryViewModelProvider).selectedDate;
    if (vmSel != null) return DateTime(vmSel.year, vmSel.month, vmSel.day);
    if (provided != null) {
      return DateTime(provided.year, provided.month, provided.day);
    }
    return dates.last;
  }

  /// Siapkan daftar tanggal dan indeks awal untuk TabController.
  ///
  /// Mengembalikan `DatesInit` yang berisi `dates` (oldest->newest) dan
  /// `initialIndex` yang cocok untuk digunakan sebagai `initialIndex` pada
  /// `TabController`.
  DatesInit prepareDates(WidgetRef ref, int daysToShow,
      {DateTime? providedSelected}) {
    final dates = generateDateList(ref, daysToShow);
    final initialSelected =
        resolveInitialSelected(ref, providedSelected, dates);
    final initIdx = findIndexForDate(dates, initialSelected);
    final initialIndex = initIdx == -1 ? (dates.length - 1) : initIdx;
    return DatesInit(dates, initialIndex);
  }

  /// Tangani ketukan (tap) pada tab dengan indeks `idx`.
  ///
  /// Memvalidasi indeks, memperbarui ViewModel dengan tanggal yang
  /// dipilih, memanggil `onDateSelected` callback bila ada, dan
  /// melakukan animasi ke tab tersebut.
  void handleTapIndex(WidgetRef ref, int idx,
      {ValueChanged<DateTime>? onDateSelected}) {
    if (_attachedDates == null || _tabController == null) {
      return;
    }
    if (idx < 0 || idx >= _attachedDates!.length) {
      return;
    }
    final d = _attachedDates![idx];
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
    final sel =
        ref.read(transactionHistoryViewModelProvider).selectedDate ?? provided;
    if (sel == null) return false;
    return sel.year == d.year && sel.month == d.month && sel.day == d.day;
  }
}
