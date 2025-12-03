import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

class CartBottomSheetController {
  CartBottomSheetController(this.ref, this.context) {
    _stateProductPos = ref.read(transactionPosViewModelProvider);
    _viewModel = ref.read(transactionPosViewModelProvider.notifier);

    _orderFocusNode = FocusNode();

    _orderNoteController =
        TextEditingController(text: _stateProductPos.orderNote);

    // Listener saat user mengetik di Order Note
    _orderNoteController.addListener(() {
      if (_orderNoteController.text != _stateProductPos.orderNote) {
        _viewModel.setOrderNote(_orderNoteController.text);
      }
    });

    // Inisialisasi controller item dari details
    _initializeItemControllers(_stateProductPos.details);
  }
  final WidgetRef ref;
  final BuildContext context;
  late FocusNode _orderFocusNode;
  final Map<int, FocusNode> _itemFocusNodes = {};
  late TextEditingController _orderNoteController;
  final Map<int, TextEditingController> _itemNoteControllers = {};
  late final Logger _logger = Logger('CartBottomSheetController');

  late final TransactionPosViewModel _viewModel;
  late final TransactionPosState _stateProductPos;
  double get cartTotal =>
      ref.read(transactionPosViewModelProvider).details.fold(0, (sum, item) {
        final subtotal =
            item.subtotal ?? ((item.productPrice ?? 0) * (item.qty ?? 0));
        return sum + subtotal;
      }).toDouble();

  double get finalTotal => cartTotal;
  TextEditingController get orderNoteController => _orderNoteController;
  FocusNode get orderFocusNode => _orderFocusNode;
  Map<int, TextEditingController> get itemNoteControllers =>
      _itemNoteControllers;
  Map<int, FocusNode> get itemFocusNodes => _itemFocusNodes;

  void activateItemNote(int id) => _activateItemNote(id);

  void unfocusAll() => _unfocusAll();

  void _initializeItemControllers(List<dynamic> details) {
    for (final item in details) {
      final id = (item as dynamic).productId ?? 0;
      if (!_itemNoteControllers.containsKey(id)) {
        final noteText = (item as dynamic).note ?? '';
        _itemNoteControllers[id] = TextEditingController(text: noteText);
        _itemFocusNodes[id] = FocusNode();
      }
    }
  }

  /// Start listening to TransactionPosState changes to synchronize controllers
  void startListening() {
    ref.listen<TransactionPosState>(transactionPosViewModelProvider,
        (previous, next) {
      if (previous == null) return;

      // A. Jika Order Note berubah dari luar
      if (previous.orderNote != next.orderNote &&
          _orderNoteController.text != next.orderNote) {
        _orderNoteController.text = next.orderNote;
      }

      // B. Logic Sinkronisasi Item Controllers
      if (previous.details.length != next.details.length) {
        // 1. Hapus controller untuk item yang hilang
        final nextIds =
            next.details.map((e) => (e as dynamic).productId).toSet();
        _itemNoteControllers.removeWhere((id, controller) {
          if (!nextIds.contains(id)) {
            controller.dispose();
            _itemFocusNodes[id]?.dispose();
            _itemFocusNodes.remove(id);
            return true;
          }
          return false;
        });

        // 2. Tambah controller untuk item baru
        for (final item in next.details) {
          final id = (item as dynamic).productId ?? 0;
          if (!_itemNoteControllers.containsKey(id)) {
            final noteText = (item as dynamic).note ?? '';
            _itemNoteControllers[id] = TextEditingController(text: noteText);
            _itemFocusNodes[id] = FocusNode();
          }
        }
      } else {
        // Jika length sama, cek apakah text note berubah dari luar
        for (final item in next.details) {
          final id = (item as dynamic).productId ?? 0;
          final controller = _itemNoteControllers[id];
          final noteText = (item as dynamic).note ?? '';
          if (controller != null && controller.text != noteText) {
            final node = _itemFocusNodes[id];
            if (node == null || !node.hasFocus) {
              controller.text = noteText;
            }
          }
        }
      }
    });
  }

  /// Handler untuk perubahan state. Harus dipanggil dari `ref.listen` yang dijalankan saat build widget
  /// untuk menghindari debug assertion dari Riverpod.
  void onStateChanged(TransactionPosState? previous, TransactionPosState next) {
    if (previous == null) return;

    // A. Jika Order Note berubah dari luar
    if (previous.orderNote != next.orderNote &&
        _orderNoteController.text != next.orderNote) {
      _orderNoteController.text = next.orderNote;
    }

    // B. Logic Sinkronisasi Item Controllers
    if (previous.details.length != next.details.length) {
      // 1. Hapus controller untuk item yang hilang
      final nextIds = next.details.map((e) => (e as dynamic).productId).toSet();
      _itemNoteControllers.removeWhere((id, controller) {
        if (!nextIds.contains(id)) {
          controller.dispose();
          _itemFocusNodes[id]?.dispose();
          _itemFocusNodes.remove(id);
          return true;
        }
        return false;
      });

      // 2. Tambah controller untuk item baru
      for (final item in next.details) {
        final id = (item as dynamic).productId ?? 0;
        if (!_itemNoteControllers.containsKey(id)) {
          _itemNoteControllers[id] =
              TextEditingController(text: (item as dynamic).note);
          _itemFocusNodes[id] = FocusNode();
        }
      }
    } else {
      // Jika length sama, cek apakah text note berubah dari luar
      for (final item in next.details) {
        final id = (item as dynamic).productId ?? 0;
        final controller = _itemNoteControllers[id];
        final noteText = (item as dynamic).note ?? '';
        if (controller != null && controller.text != noteText) {
          final node = _itemFocusNodes[id];
          if (node == null || !node.hasFocus) {
            controller.text = noteText;
          }
        }
      }
    }
  }

  void onUpdateQuantity(int id, int delta) async {
    await _viewModel.setUpdateQuantity(id, delta);
    final int total = _viewModel.cartCount;

    _logger.info("total cart items after update: $total");

    // Only proceed if the context is still mounted
    if (context.mounted) {
      if (total == 0) {
        FocusScope.of(context).unfocus();
        // Close the modal bottom sheet if it's open.
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void onClearCart() {
    _viewModel.onClearCart();

    FocusScope.of(context).unfocus();
    // Close the modal bottom sheet if it's open.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void dispose() {
    _orderNoteController.dispose();
    _orderFocusNode.dispose();
    for (final controller in _itemNoteControllers.values) {
      controller.dispose();
    }
    for (final node in _itemFocusNodes.values) {
      node.dispose();
    }
  }

  void _unfocusAll() {
    FocusScope.of(context).unfocus();
  }

  void _activateItemNote(int id) {
    // Unfocus yang lain
    for (final nodeId in _itemFocusNodes.keys) {
      if (nodeId != id) {
        _itemFocusNodes[nodeId]?.unfocus();
      }
    }
    _orderFocusNode.unfocus();
    // Fokus ke item yang dipilih agar keyboard muncul segera
    _itemFocusNodes[id]?.requestFocus();
  }

  void onActivateItemNote(int id) {
    // Unfocus yang lain
    for (final nodeId in _itemFocusNodes.keys) {
      if (nodeId != id) {
        _itemFocusNodes[nodeId]?.unfocus();
      }
    }
    _orderFocusNode.unfocus();
    // Fokus ke item yang dipilih agar keyboard muncul segera
    _itemFocusNodes[id]?.requestFocus();
  }
}
