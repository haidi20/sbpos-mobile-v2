import 'package:core/core.dart';
import 'package:transaction/presentation/ui_models/order_type_item.um.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

class CartMethodPaymentController {
  CartMethodPaymentController(this.ref, this.context) {
    _viewModel = ref.read(transactionPosViewModelProvider.notifier);
  }

  final WidgetRef ref;
  final BuildContext context;
  late final TransactionPosViewModel _viewModel;

  Future<void> onProcess() async {
    final state = ref.read(transactionPosViewModelProvider);

    if (state.orderType == EOrderType.online && (state.ojolProvider.isEmpty)) {
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
    _viewModel.clearAll();
    // Navigasi ke halaman daftar transaksi menggunakan router singleton
    AppRouter.instance.router.go(AppRoutes.transaction);
  }

  void onToggleView() {
    final state = ref.read(transactionPosViewModelProvider);
    final next = state.viewMode == 'cart' ? 'checkout' : 'cart';
    _viewModel.setViewMode(next);
  }

  // View model ringan untuk tipe pesanan yang digunakan oleh widget
  // Menjaga logika presentasi tetap berada di controller, bukan di file widget.
  List<OrderTypeItemUiModel> getOrderTypeItems() {
    final state = ref.read(transactionPosViewModelProvider);
    final raw = _viewModel.getOrderTypes; // List<Map<String, Object?>>
    return raw.map((m) {
      final id = (m['id'] as String);
      final label = (m['label'] as String);
      final icon = (m['icon'] as IconData);
      final selected =
          (id == 'dine_in' && state.orderType == EOrderType.dineIn) ||
              (id == 'take_away' && state.orderType == EOrderType.takeAway) ||
              (id == 'online' && state.orderType == EOrderType.online);
      return OrderTypeItemUiModel(
        id: id,
        icon: icon,
        label: label,
        selected: selected,
      );
    }).toList();
  }

  void selectOrderTypeById(String id) {
    final type = id == 'dine_in'
        ? EOrderType.dineIn
        : id == 'take_away'
            ? EOrderType.takeAway
            : EOrderType.online;
    _viewModel.setOrderType(type);
  }
}
