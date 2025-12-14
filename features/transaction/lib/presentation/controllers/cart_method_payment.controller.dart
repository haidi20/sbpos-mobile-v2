import 'package:core/core.dart';
import 'package:transaction/presentation/ui_models/order_type_item.um.dart';
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
  List<OrderTypeItemUiModel> getOrderTypeItems() =>
      _viewModel.getOrderTypeItems();

  /// Pilih order type berdasarkan id (delegasi ke ViewModel).
  void selectOrderTypeById(String id) => _viewModel.selectOrderTypeById(id);

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
