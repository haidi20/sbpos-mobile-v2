import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
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
  int? _lastRequestedActiveId;
  DateTime? _lastActiveChangeAt;
  int? _pendingFocusId;
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

  /// Set active item note id and manage focus consistently
  void setActiveItemNoteId(int? id) {
    // Prevent redundant calls that retrigger input restart
    final currentActive =
        ref.read(transactionPosViewModelProvider).activeNoteId;
    if (id == currentActive) {
      return;
    }
    // Lightweight debounce to avoid rapid toggles during rebuilds
    final now = DateTime.now();
    if (_lastRequestedActiveId == id &&
        _lastActiveChangeAt != null &&
        now.difference(_lastActiveChangeAt!).inMilliseconds < 100) {
      return;
    }
    _lastRequestedActiveId = id;
    _lastActiveChangeAt = now;

    if (id == null) {
      _logger.info('Set activeNoteId -> null, unfocus all');
      // Update provider first so UI rebuild reflects null immediately
      _viewModel.setActiveNoteId(null);
      // Then unfocus to avoid IME restart causing stale reads
      _unfocusAll();
      return;
    }

    _logger.info('Set activeNoteId -> $id, focus that item');
    // Update provider first so dependent widgets see the new active id
    _viewModel.setActiveNoteId(id);
    // Unfocus others then focus target node
    _unfocusAll();
    final node = _itemFocusNodes[id];
    node?.requestFocus();
  }

  /// Check if a tap is within any currently focused input
  bool isTapInsideAnyFocused(Offset globalPosition) {
    // Check focused order note
    if (_orderFocusNode.hasFocus) {
      final ctx = _orderFocusNode.context;
      final render = ctx?.findRenderObject();
      if (render is RenderBox) {
        final local = render.globalToLocal(globalPosition);
        final rect = Offset.zero & render.size;
        if (rect.contains(local)) return true;
      }
    }
    // Check focused item notes
    for (final entry in _itemFocusNodes.entries) {
      final node = entry.value;
      if (!node.hasFocus) continue;
      final ctx = node.context;
      final render = ctx?.findRenderObject();
      if (render is RenderBox) {
        final local = render.globalToLocal(globalPosition);
        final rect = Offset.zero & render.size;
        if (rect.contains(local)) return true;
      }
    }
    return false;
  }

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
      // Gunakan handler terpusat agar logika fokus/aktif konsisten
      onStateChanged(previous, next);
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
      // If active item is being removed, clear active and unfocus before disposing controllers
      if (previous.activeNoteId != null &&
          !nextIds.contains(previous.activeNoteId)) {
        _logger.info(
            'Active item ${previous.activeNoteId} removed; clear active and unfocus before disposal');
        // Jangan langsung unfocus untuk menghindari restart IME jika item akan segera muncul kembali.
        // Tandai agar difokuskan kembali bila id yang sama ditambahkan di state berikutnya.
        _pendingFocusId = previous.activeNoteId;
        _viewModel.setActiveNoteId(null);
      }
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
      for (final TransactionDetailEntity item in next.details) {
        final id = (item as dynamic).productId ?? 0;
        if (!_itemNoteControllers.containsKey(id)) {
          _itemNoteControllers[id] = TextEditingController(text: item.note);
          _itemFocusNodes[id] = FocusNode();
          // Jika item yang dihapus sebelumnya adalah yang aktif dan muncul kembali, kembalikan fokus.
          if (_pendingFocusId != null && id == _pendingFocusId) {
            _logger.info('Restoring focus to re-added item $id');
            final node = _itemFocusNodes[id];
            node?.requestFocus();
            _viewModel.setActiveNoteId(id);
            _pendingFocusId = null;
          }
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
    // Avoid modifying providers during unmount; only unfocus nodes locally
    for (final node in _itemFocusNodes.values) {
      node.unfocus();
    }
    _orderFocusNode.unfocus();
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
    // Safely unfocus only when context is mounted and focus scope exists
    if (context.mounted) {
      FocusScopeNode? scope;
      try {
        scope = FocusScope.of(context);
      } catch (_) {
        scope = null;
      }
      scope?.unfocus();
    }
    // Also unfocus individual nodes to be thorough
    for (final node in _itemFocusNodes.values) {
      node.unfocus();
    }
    _orderFocusNode.unfocus();
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
