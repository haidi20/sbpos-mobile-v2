import 'package:core/core.dart';
import 'package:product/domain/entities/cart_entity.dart';
import 'package:product/presentation/view_models/product_pos.vm.dart';
import 'package:product/presentation/view_models/product_pos.state.dart';
import 'package:product/presentation/providers/product_pos_provider.dart';

class CartBottomSheetController {
  CartBottomSheetController(this.ref, this.context) {
    _stateProductPos = ref.read(productPosViewModelProvider);
    _viewModel = ref.read(productPosViewModelProvider.notifier);

    _orderFocusNode = FocusNode();

    _orderNoteController =
        TextEditingController(text: _stateProductPos.orderNote);

    // Listener saat user mengetik di Order Note
    _orderNoteController.addListener(() {
      if (_orderNoteController.text != _stateProductPos.orderNote) {
        _viewModel.setOrderNote(_orderNoteController.text);
      }
    });

    // Inisialisasi controller item
    _initializeItemControllers(_stateProductPos.cart);
  }
  // static final Logger _logger = Logger('ProductPosController');

  final WidgetRef ref;
  final BuildContext context;

  static final Logger _logger = Logger('CartBottomSheetController');
  late FocusNode _orderFocusNode;
  final Map<int, FocusNode> _itemFocusNodes = {};
  late TextEditingController _orderNoteController;
  final Map<int, TextEditingController> _itemNoteControllers = {};

  late final ProductPosViewModel _viewModel;
  late final ProductPosState _stateProductPos;

  double get cartTotal => ref
      .read(productPosViewModelProvider)
      .cart
      .fold(0, (sum, item) => sum + item.subtotal);

  double get finalTotal => cartTotal;
  TextEditingController get orderNoteController => _orderNoteController;
  FocusNode get orderFocusNode => _orderFocusNode;
  Map<int, TextEditingController> get itemNoteControllers =>
      _itemNoteControllers;
  Map<int, FocusNode> get itemFocusNodes => _itemFocusNodes;

  void activateItemNote(int id) => _activateItemNote(id);

  void unfocusAll() => _unfocusAll();

  void _initializeItemControllers(List<CartItemEntity> cart) {
    for (final item in cart) {
      final id = item.product.id ?? 0;
      if (!_itemNoteControllers.containsKey(id)) {
        _itemNoteControllers[id] = TextEditingController(text: item.note);
        _itemFocusNodes[id] = FocusNode();
      }
    }
  }

  /// Start listening to ProductPosState changes to synchronize controllers
  void startListening() {
    ref.listen<ProductPosState>(productPosViewModelProvider, (previous, next) {
      if (previous == null) return;

      // A. Jika Order Note berubah dari luar
      if (previous.orderNote != next.orderNote &&
          _orderNoteController.text != next.orderNote) {
        _orderNoteController.text = next.orderNote;
      }

      // B. Logic Sinkronisasi Item Controllers
      if (previous.cart.length != next.cart.length) {
        // 1. Hapus controller untuk item yang hilang
        final nextIds = next.cart.map((e) => e.product.id).toSet();
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
        for (final item in next.cart) {
          final id = item.product.id ?? 0;
          if (!_itemNoteControllers.containsKey(id)) {
            _itemNoteControllers[id] = TextEditingController(text: item.note);
            _itemFocusNodes[id] = FocusNode();
          }
        }
      } else {
        // Jika length sama, cek apakah text note berubah dari luar
        for (final item in next.cart) {
          final id = item.product.id ?? 0;
          final controller = _itemNoteControllers[id];
          if (controller != null && controller.text != item.note) {
            if (!(_itemFocusNodes[id]?.hasFocus ?? false)) {
              controller.text = item.note;
            }
          }
        }
      }
    });
  }

  /// Handler untuk perubahan state. Harus dipanggil dari `ref.listen` yang dijalankan saat build widget
  /// untuk menghindari debug assertion dari Riverpod.
  void onStateChanged(ProductPosState? previous, ProductPosState next) {
    if (previous == null) return;

    // A. Jika Order Note berubah dari luar
    if (previous.orderNote != next.orderNote &&
        _orderNoteController.text != next.orderNote) {
      _orderNoteController.text = next.orderNote;
    }

    // B. Logic Sinkronisasi Item Controllers
    if (previous.cart.length != next.cart.length) {
      // 1. Hapus controller untuk item yang hilang
      final nextIds = next.cart.map((e) => e.product.id).toSet();
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
      for (final item in next.cart) {
        final id = item.product.id ?? 0;
        if (!_itemNoteControllers.containsKey(id)) {
          _itemNoteControllers[id] = TextEditingController(text: item.note);
          _itemFocusNodes[id] = FocusNode();
        }
      }
    } else {
      // Jika length sama, cek apakah text note berubah dari luar
      for (final item in next.cart) {
        final id = item.product.id ?? 0;
        final controller = _itemNoteControllers[id];
        if (controller != null && controller.text != item.note) {
          if (!(_itemFocusNodes[id]?.hasFocus ?? false)) {
            controller.text = item.note;
          }
        }
      }
    }
  }

  void onUpdateQuantity(int id, int delta) {
    _viewModel.setUpdateQuantity(id, delta);
    final stateProductPos = ref.read(productPosViewModelProvider);

    final int total = stateProductPos.cart.length;

    // _logger.info("total cart items after update: $total");

    if (total == 0) {
      FocusScope.of(context).unfocus();
      // Close the modal bottom sheet if it's open.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
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
