import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';
import 'package:dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dashboard/presentation/view_models/dashboard.state.dart';

class CartPaymentController {
  final WidgetRef ref;
  final BuildContext context;
  VoidCallback? _cashListener;
  VoidCallback? _tableListener;
  late TransactionPosState _state;
  late final TransactionPosViewModel _viewModel;
  late final TextEditingController cashController;
  late final TextEditingController tableNumberController;
  final Logger _logger = Logger('CartPaymentController');
  int? _cachedCashForEdit;

  CartPaymentController(this.ref, this.context) {
    _state = ref.read(transactionPosViewModelProvider);
    _viewModel = ref.read(transactionPosViewModelProvider.notifier);
    // inisialisasi `cashController` dari state saat ini
    cashController = TextEditingController(
        text: _state.cashReceived > 0 ? _state.cashReceived.toString() : '');
    _cashListener = () {
      final raw = cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final v = int.tryParse(raw) ?? 0;
      if (v != _state.cashReceived) {
        _viewModel.setCashReceived(v);
      }
    };
    cashController.addListener(_cashListener!);

    // inisialisasi `tableNumberController` dari state saat ini
    tableNumberController = TextEditingController(
        text:
            (_state.tableNumber ?? 0) > 0 ? _state.tableNumber.toString() : '');
    _tableListener = () {
      final raw = tableNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final v = int.tryParse(raw);
      if (v != _state.tableNumber) {
        _viewModel.setTableNumber(v);
      }
    };
    tableNumberController.addListener(_tableListener!);
  }

  /// Toggle flag isPaid dengan perilaku khusus saat mode edit.
  ///
  /// - Mode create: hanya set isPaid seperti biasa.
  /// - Mode edit:
  ///   * Saat uncheck: simpan nominal lama ke cache, kosongkan cashReceived
  ///     dan field input (cashController).
  ///   * Saat check lagi: kembalikan nominal dari cache (jika ada).
  void onToggleIsPaid(bool newValue) {
    final isEditMode = _state.transactionMode == ETransactionMode.edit;

    if (!isEditMode) {
      _viewModel.setIsPaid(newValue);
      return;
    }

    if (!newValue) {
      // Uncheck di mode edit: simpan nilai lama lalu kosongkan.
      _cachedCashForEdit = _state.cashReceived;
      _viewModel.setIsPaid(false);
      _viewModel.setCashReceived(0);
      cashController.text = '';
    } else {
      // Check kembali di mode edit: pulihkan nilai jika tersedia.
      _viewModel.setIsPaid(true);
      if (_cachedCashForEdit != null) {
        final v = _cachedCashForEdit!;
        _viewModel.setCashReceived(v);
        cashController.text = v > 0 ? v.toString() : '';
      }
    }
  }

  Future<void> onProcess() async {
    _logger.info('CartPaymentController.onProcess called');

    // return; // (baris ini dikomentari)
    // gunakan state yang di-cache dan diinisialisasi di konstruktor
    if (_state.orderType == EOrderType.online &&
        (_state.ojolProvider.isEmpty)) {
      _viewModel.setShowErrorSnackbar(true);

      Future.delayed(
        const Duration(seconds: 3),
        () => _viewModel.setShowErrorSnackbar(false),
      );

      return;
    }

    // Tangkap notifier eksternal secara sinkron untuk menghindari penggunaan `ref`
    // setelah widget mungkin telah di-dispose selama operasi await.
    final historyNotifier =
        ref.read(transactionHistoryViewModelProvider.notifier);
    final dashboardNotifier = ref.read(dashboardViewModelProvider.notifier);

    // Tutup `CartBottomSheet` jika terbuka sebelum proses, supaya UI kembali ke layar utama.
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    // Simpan transaksi di latar belakang tapi tunggu sampai selesai (status akan menjadi 'proses')
    await _viewModel.onStore();

    // Setelah berhasil disimpan, reset seluruh state POS ke kondisi awal
    _viewModel.onClearAll();

    // Segarkan riwayat transaksi agar dashboard menampilkan pesanan baru,
    // kemudian aktifkan tab Orders dan navigasi ke dashboard.
    try {
      await historyNotifier.onRefresh();
    } catch (_) {}

    dashboardNotifier.onTabChange(AppTab.orders);
    AppRouter.instance.router.go(AppRoutes.dashboard);
  }

  /// Mulai mendengarkan perubahan state untuk menyinkronkan `cashController`.
  /// Sinkronisasi state controller saat state transaksi berubah.
  /// Metode ini aman dipanggil dari callback `ref.listen` (misal dari
  /// metode `build` widget) untuk menjaga controller tetap sinkron
  /// dengan `TransactionPosState` terbaru.
  void syncFromState(TransactionPosState? previous, TransactionPosState next) {
    if (previous == null) {
      _state = next;
      return;
    }

    // Jika cashReceived diubah dari luar (VM), sinkronkan controller
    if (previous.cashReceived != next.cashReceived) {
      final ctrlVal =
          int.tryParse(cashController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
              0;
      if (ctrlVal != next.cashReceived) {
        // Jangan ganggu jika field sedang difokuskan oleh pengguna
        final focusScope = FocusManager.instance.primaryFocus;
        if (focusScope == null || !focusScope.hasFocus) {
          cashController.text =
              next.cashReceived > 0 ? next.cashReceived.toString() : '';
        }
      }
    }

    // Sinkronkan nomor meja jika berubah dari luar
    if (previous.tableNumber != next.tableNumber) {
      final ctrlVal = int.tryParse(
              tableNumberController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      final nextVal = next.tableNumber ?? 0;
      if (ctrlVal != nextVal) {
        final focusScope = FocusManager.instance.primaryFocus;
        if (focusScope == null || !focusScope.hasFocus) {
          tableNumberController.text = nextVal > 0 ? nextVal.toString() : '';
        }
      }
    }
    _state = next;
  }

  /// Lepaskan listener controller (dipanggil dari screen.dispose)
  void dispose() {
    try {
      if (_cashListener != null) cashController.removeListener(_cashListener!);
      cashController.dispose();
      if (_tableListener != null) {
        tableNumberController.removeListener(_tableListener!);
      }
      tableNumberController.dispose();
    } catch (_) {}
  }

  // UI Handlers moved from widget into controller/VM layer
  void onCashTextChanged(String txt) {
    final raw = txt.trim();
    final v = int.tryParse(raw) ?? 0;
    _viewModel.setCashReceived(v);
    final total = _viewModel.getGrandTotalValue;
    _viewModel.setIsPaid(v >= total);
  }

  void setCashToExact() {
    final total = _viewModel.getGrandTotalValue;
    cashController.text = total > 0 ? total.toString() : '';
    _viewModel.setCashReceived(total);
    _viewModel.setIsPaid(true);
  }

  void setCashToSuggested() {
    final total = _viewModel.getGrandTotalValue;
    final sug = _viewModel.suggestQuickCash(total);
    cashController.text = sug > 0 ? sug.toString() : '';
    _viewModel.setCashReceived(sug);
    _viewModel.setIsPaid(sug >= total);
  }
}
