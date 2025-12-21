import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dashboard/presentation/view_models/dashboard.state.dart';

class CartPaymentController {
  final WidgetRef ref;
  final BuildContext context;
  VoidCallback? _cashListener;
  late TransactionPosState _state;
  late final TransactionPosViewModel _viewModel;
  late final TextEditingController cashController;
  final Logger _logger = Logger('CartPaymentController');

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
    _state = next;
  }

  /// Lepaskan listener controller (dipanggil dari screen.dispose)
  void dispose() {
    try {
      if (_cashListener != null) cashController.removeListener(_cashListener!);
      cashController.dispose();
    } catch (_) {}
  }
}
