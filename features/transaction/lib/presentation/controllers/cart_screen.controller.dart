// ignore_for_file: gunakan_build_context_synchronously

import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';

class CartScreenController {
  CartScreenController(this.ref, this.context) {
    // Controller sheet draggable dan notifier ukuran
    sheetController = DraggableScrollableController();
    _sheetListener = () {
      sheetSize.value = sheetController.size;
    };
    sheetController.addListener(_sheetListener!);
    _stateProductPos = ref.read(transactionPosViewModelProvider);
    _viewModel = ref.read(transactionPosViewModelProvider.notifier);

    _orderFocusNode = FocusNode();

    _orderNoteController =
        TextEditingController(text: _stateProductPos.orderNote);

    // Listener saat gunakanr mengetik di Order Note
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
  late final DraggableScrollableController sheetController;
  VoidCallback? _sheetListener;

  /// Ukuran sheet saat ini (0.0 - 1.0)
  final ValueNotifier<double> sheetSize = ValueNotifier<double>(1.0);
  late FocusNode _orderFocusNode;
  final Map<int, FocusNode> _itemFocusNodes = {};
  late TextEditingController _orderNoteController;
  final Map<int, TextEditingController> _itemNoteControllers = {};
  late final Logger _logger = Logger('CartScreenController');

  late final TransactionPosViewModel _viewModel;
  late final TransactionPosState _stateProductPos;
  int? _lastRequestedActiveId;
  DateTime? _lastActiveChangeAt;
  int? _pendingFocusId;
  final Set<int> _openNoteEditorIds = {};
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

  /// Set active id catatan item dan kelola fokus secara konsisten
  Future<void> setActiveItemNoteId(int? id) async {
    // Cegah pemanggilan berulang yang memicu restart input
    final currentActive =
        ref.read(transactionPosViewModelProvider).activeNoteId;
    if (id == currentActive) {
      return;
    }
    // Debounce ringan untuk menghindari toggle cepat saat rebuild
    final now = DateTime.now();
    if (_lastRequestedActiveId == id &&
        _lastActiveChangeAt != null &&
        now.difference(_lastActiveChangeAt!).inMilliseconds < 100) {
      return;
    }
    _lastActiveChangeAt = now;
    _lastRequestedActiveId = id;

    if (id == null) {
      _logger.info('Set activeNoteId -> null, unfocus all');
      // Perbarui provider terlebih dahulu agar UI merefleksikan null segera
      // Perbarui UI langsung dan simpan di latar belakang.
      unawaited(_viewModel.setActiveNoteId(null, background: true));
      // Kemudian unfocus untuk menghindari restart IME yang menyebabkan bacaan usang
      _unfocusAll();
      return;
    }

    _logger.info('Set activeNoteId -> $id, focus that item');
    // Perbarui provider first so dependent widgets see the new active id
    unawaited(_viewModel.setActiveNoteId(id, background: true));
    // Unfocus others then focus target node
    _unfocusAll();
    final node = _itemFocusNodes[id];
    node?.requestFocus();
  }

  /// Periksa apakah ketukan berada di dalam input yang sedang fokus
  bool isTapInsideAnyFocused(Offset globalPosition) {
    // Cek order catatan yang sedang fokus
    if (_orderFocusNode.hasFocus) {
      final ctx = _orderFocusNode.context;
      final render = ctx?.findRenderObject();
      if (render is RenderBox) {
        final local = render.globalToLocal(globalPosition);
        final rect = Offset.zero & render.size;
        if (rect.contains(local)) return true;
      }
    }
    // Cek catatan item yang sedang fokus
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

  /// Mulai mendengarkan perubahan `TransactionPosState` untuk menyinkronkan controller
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
      // Jika item aktif dihapus, bersihkan status aktif dan unfokus sebelum membuang controller
      if (previous.activeNoteId != null &&
          !nextIds.contains(previous.activeNoteId)) {
        _logger.info(
            'Active item ${previous.activeNoteId} removed; clear active and unfocus before disposal');
        // Jangan langsung unfocus untuk menghindari restart IME jika item akan segera muncul kembali.
        // Tandai agar difokuskan kembali bila id yang sama ditambahkan di state berikutnya.
        _pendingFocusId = previous.activeNoteId;
        unawaited(_viewModel.setActiveNoteId(null, background: true));
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
            unawaited(_viewModel.setActiveNoteId(id, background: true));
            _pendingFocusId = null;
          }
        }
      }
    } else {
      // Jika panjang sama, cek apakah teks catatan berubah dari luar
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
    final int total = _viewModel.getCartCount;

    _logger.info("total cart items after update: $total");

    // Lanjutkan hanya jika `context` masih ter-mount
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

  /// Show item catatan editor as a bottom-up sheet for the given `id`.
  /// Guards against opening multiple sheets for the same item.
  Future<void> showItemNoteEditor(int id) {
    if (_openNoteEditorIds.contains(id)) return Future.value();
    _openNoteEditorIds.add(id);

    final controller = _itemNoteControllers[id] ?? TextEditingController();

    if (!context.mounted) {
      _openNoteEditorIds.remove(id);
      return Future.value();
    }

    final hostContext = context;

    return FullScreenTextEditor.showAsBottomSheet<void>(
      hostContext,
      controller: controller,
      onSave: (value) async {
        await _viewModel.setItemNote(id, value);
      },
      title: 'Catatan',
      hintText: 'tulis catatan...',
    ).whenComplete(() {
      _openNoteEditorIds.remove(id);
      unawaited(_viewModel.setActiveNoteId(null, background: true));
    });
  }

  // Controller scroll konten opsional (disediakan oleh CartScreen)
  ScrollController? _contentScrollController;

  /// Tetapkan `ScrollController` luar/konten sehingga controller dapat melakukan
  /// scrolling programatis yang aman atas nama widget anak.
  void setContentScrollController(ScrollController? controller) {
    _contentScrollController = controller;
  }

  /// Menggulir konten sejauh `pixels` piksel.
  /// - `pixels` dapat bernilai positif atau negatif.
  /// - Positif (`25`) menggeser ke bawah (menaikkan offset),
  ///   Negatif (`-25`) menggeser ke atas (menurunkan offset).
  /// Mengembalikan `Future` yang selesai ketika animasi selesai (atau selesai
  /// segera jika controller tidak tersedia).
  Future<void> scrollContentBy(double pixels) async {
    final c = _contentScrollController;
    if (c == null || !c.hasClients) return;
    final current = c.position.pixels;
    // Positive pixels => move down (increase offset). Negative => move up.
    final dy = pixels;
    final targetRaw = current + dy;
    final target = targetRaw < 0.0 ? 0.0 : targetRaw;
    final bounded = target > c.position.maxScrollExtent
        ? c.position.maxScrollExtent
        : target;

    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = _contentScrollController;
      if (ctrl == null || !ctrl.hasClients) {
        completer.complete();
        return;
      }
      try {
        ctrl
            .animateTo(
              bounded,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            )
            .then((_) => completer.complete())
            .catchError((_) => completer.complete());
      } catch (_) {
        completer.complete();
      }
    });

    return completer.future;
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

  Future<void> onClearCart() async {
    await _viewModel.onClearCart();

    _logger.info("Cart cleared");

    // Unfocus semua input dan tutup bottom sheet jika keranjang kosong
    if (context.mounted) {
      FocusScope.of(context).unfocus();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void dispose() {
    // Hindari memodifikasi provider saat unmount; hanya unfocus node secara lokal
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
    // Buang sheet controller dan listener
    try {
      if (_sheetListener != null) {
        sheetController.removeListener(_sheetListener!);
      }
      sheetController.dispose();
    } catch (_) {}
    sheetSize.dispose();
  }

  void _unfocusAll() {
    // Safely unfocus hanya ketika `context` ter-mount dan fokus scope tersedia
    if (context.mounted) {
      FocusScopeNode? scope;
      try {
        scope = FocusScope.of(context);
      } catch (_) {
        scope = null;
      }
      scope?.unfocus();
    }
    // Juga unfocus node individu untuk memastikan
    for (final node in _itemFocusNodes.values) {
      node.unfocus();
    }
    _orderFocusNode.unfocus();
  }
}
