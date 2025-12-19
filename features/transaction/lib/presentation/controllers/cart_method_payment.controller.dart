import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

class CartMethodPaymentController {
  CartMethodPaymentController(this.ref, this.context) {
    _state = ref.read(transactionPosViewModelProvider);
    _viewModel = ref.read(transactionPosViewModelProvider.notifier);
  }

  final WidgetRef ref;
  final BuildContext context;
  late TransactionPosState _state;
  late final TransactionPosViewModel _viewModel;

  /// Mengembalikan daftar tipe order siap pakai untuk UI selector.
  // Controller no longer exposes order-type helpers; the screen should
  // access the view-model directly for order-type listing and selection.

  /// Toggle view mode (delegasi ke ViewModel).
  void onToggleView() => _viewModel.onToggleView();

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
    // Navigasi ke halaman daftar transaksi menggunakan router singleton
    AppRouter.instance.router.go(AppRoutes.transactionHistory);
  }
}
