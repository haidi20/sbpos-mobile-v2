import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dashboard/presentation/view_models/dashboard.state.dart';

class CartPaymentController {
  final WidgetRef ref;
  final BuildContext context;
  late TransactionPosState _state;
  late final TransactionPosViewModel _viewModel;
  late final TextEditingController cashController;
  VoidCallback? _cashListener;

  CartPaymentController(this.ref, this.context) {
    _state = ref.read(transactionPosViewModelProvider);
    _viewModel = ref.read(transactionPosViewModelProvider.notifier);
    // initialize cash controller from current state
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
    // use cached state initialized in constructor
    if (_state.orderType == EOrderType.online &&
        (_state.ojolProvider.isEmpty)) {
      _viewModel.setShowErrorSnackbar(true);

      Future.delayed(
        const Duration(seconds: 3),
        () => _viewModel.setShowErrorSnackbar(false),
      );

      return;
    }

    // Simpan transaksi di latar belakang tapi tunggu sampai selesai (status akan menjadi 'proses')
    await _viewModel.onStore();

    // Setelah berhasil disimpan, reset seluruh state POS ke kondisi awal
    _viewModel.onClearAll();
    // Aktifkan tab Orders pada dashboard lalu navigasi ke dashboard
    ref.read(dashboardViewModelProvider.notifier).onTabChange(AppTab.orders);
    AppRouter.instance.router.go(AppRoutes.dashboard);
  }

  /// Mulai mendengarkan perubahan state untuk menyinkronkan `cashController`.
  /// Synchronize controller state when transaction state changes.
  ///
  /// This method is safe to call from a `ref.listen` callback (from the
  /// widget's `build` method) to keep the controller in sync with the
  /// latest `TransactionPosState`.
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
        // Jangan ganggu jika field sedang difokuskan oleh user
        final focusScope = FocusManager.instance.primaryFocus;
        if (focusScope == null || !focusScope.hasFocus) {
          cashController.text =
              next.cashReceived > 0 ? next.cashReceived.toString() : '';
        }
      }
    }
    _state = next;
  }

  /// Dispose controller listeners (dipanggil dari screen.dispose)
  void dispose() {
    try {
      if (_cashListener != null) cashController.removeListener(_cashListener!);
      cashController.dispose();
    } catch (_) {}
  }
}
