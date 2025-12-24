import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/domain/usecases/get_packets.usecase.dart';
import 'package:product/domain/usecases/create_packet.usecase.dart';
import 'package:product/domain/usecases/update_packet.usecase.dart';
import 'package:product/domain/usecases/delete_packet.usecase.dart';
import 'package:product/presentation/view_models/packet_management.state.dart';

class PacketManagementViewModel extends StateNotifier<PacketManagementState> {
  PacketManagementViewModel({
    required GetPackets getPacketsUsecase,
    required CreatePacket createPacketUsecase,
    required UpdatePacket updatePacketUsecase,
    required DeletePacket deletePacketUsecase,
    this.onAfterCrud,
  })  : _getPacketsUsecase = getPacketsUsecase,
        _createPacketUsecase = createPacketUsecase,
        _updatePacketUsecase = updatePacketUsecase,
        _deletePacketUsecase = deletePacketUsecase,
        super(PacketManagementState());

  final GetPackets _getPacketsUsecase;
  final CreatePacket _createPacketUsecase;
  final UpdatePacket _updatePacketUsecase;
  final DeletePacket _deletePacketUsecase;
  final Future<void> Function()? onAfterCrud;
  // final _logger = Logger('PacketManagementViewModel');
  // -------------------------
  // Getters (public)
  // -------------------------
  PacketEntity get draft => _draft;

  /// Mengembalikan tampilan tak dapat diubah dari id terpilih dan kuantitasnya.
  Map<int, int> get selectedMap => Map<int, int>.unmodifiable(_qtys);

  /// Tampilan tak dapat diubah dari id produk yang dipilih.
  Set<int> get selectedIds => Set<int>.unmodifiable(_selectedIds);

  // -------------------------
  // Setters (public - methods named `set*`)
  // -------------------------
  void setIsForm(bool v) => state = state.copyWith(isForm: v);

  void setDraft(PacketEntity p) => _draft = p;

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  // -------------------------
  // Public helpers / actions
  // -------------------------
  /// Inisialisasi state seleksi dari item paket.
  void initSelectionFromPacket(PacketEntity packet) {
    _selectedIds = {
      for (final it in packet.items ?? [])
        if (it.productId != null) it.productId!
    };
    _qtys = {
      for (final it in packet.items ?? [])
        if (it.productId != null) it.productId!: (it.qty ?? 1)
    };
    // trigger UI update
    state = state.copyWith(loading: state.loading);
  }

  bool isSelected(int productId) => _selectedIds.contains(productId);

  int qtyFor(int productId, [int fallback = 1]) => _qtys[productId] ?? fallback;

  void toggleSelected(int productId) {
    if (_selectedIds.contains(productId)) {
      _selectedIds.remove(productId);
      // keep qty as 0 when unselected
      _qtys[productId] = 0;
    } else {
      _selectedIds.add(productId);
      // pastikan qty minimal 1 saat dipilih
      final current = _qtys[productId] ?? 0;
      _qtys[productId] = current <= 0 ? 1 : current;
    }
    state = state.copyWith(loading: state.loading);
  }

  void incrementQty(int productId) {
    final current = _qtys[productId] ?? 0;
    final next = (current + 1).clamp(1, 999).toInt();
    _qtys[productId] = next;
    // auto-select when incrementing from zero
    if (next > 0) _selectedIds.add(productId);
    state = state.copyWith(loading: state.loading);
  }

  void decrementQty(int productId) {
    final current = _qtys[productId] ?? 0;
    final next = (current - 1).clamp(0, 999).toInt();
    _qtys[productId] = next;
    // if qty drops to 0, unselect the item
    if (next == 0) _selectedIds.remove(productId);
    state = state.copyWith(loading: state.loading);
  }

  // -------------------------
  // Events (public - `on*` methods)
  // -------------------------
  Future<void> getPackets() async {
    state = state.copyWith(loading: true);
    try {
      final res = await _getPacketsUsecase(isOffline: true);
      res.fold((f) {
        state = state.copyWith(loading: false, error: f.message);
      }, (list) {
        state = state.copyWith(loading: false, packets: list);
      });
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> onCreatePacket() async {
    final res = await _createPacketUsecase(_draft, isOffline: true);
    res.fold((f) => state = state.copyWith(error: f.message), (created) {
      state =
          state.copyWith(packets: [...state.packets, created], isForm: false);
      _draft = PacketEntity();
      try {
        final f = onAfterCrud?.call();
        if (f != null) {
          unawaited(f.catchError((e, st) => Logger('PacketManagementVM')
              .warning('onAfterCrud failed', e, st)));
        }
      } catch (_) {}
    });
  }

  Future<void> onUpdatePacket() async {
    final res = await _updatePacketUsecase(_draft, isOffline: true);
    res.fold((f) => state = state.copyWith(error: f.message), (updated) {
      state = state.copyWith(
        packets:
            state.packets.map((p) => p.id == updated.id ? updated : p).toList(),
        isForm: false,
      );
      _draft = PacketEntity();
      try {
        unawaited(onAfterCrud?.call());
      } catch (_) {}
    });
  }

  Future<bool> onDeletePacketById(int? id) async {
    try {
      if (id == null) return false;
      final res = await _deletePacketUsecase(id, isOffline: true);
      return res.fold((f) {
        state = state.copyWith(error: f.message);
        return false;
      }, (ok) {
        if (ok) {
          state = state.copyWith(
              packets: state.packets.where((p) => p.id != id).toList());
          try {
            unawaited(onAfterCrud?.call());
          } catch (_) {}
        }
        return ok;
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // -------------------------
  // Draft item management (public)
  // -------------------------
  void addDraftItem(PacketItemEntity item) {
    final items = List<PacketItemEntity>.from(_draft.items ?? [])..add(item);
    _draft = _draft.copyWith(items: items);
    // trigger state update so UI listening to the state rebuilds
    state = state.copyWith(loading: state.loading);
  }

  void updateDraftItemAt(int index, PacketItemEntity item) {
    final items = List<PacketItemEntity>.from(_draft.items ?? []);
    if (index < 0 || index >= items.length) return;
    items[index] = item;
    _draft = _draft.copyWith(items: items);
    state = state.copyWith(loading: state.loading);
  }

  void removeDraftItemAt(int index) {
    final items = List<PacketItemEntity>.from(_draft.items ?? []);
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    _draft = _draft.copyWith(items: items);
    state = state.copyWith(loading: state.loading);
  }

  // -------------------------
  // Private fields
  // -------------------------
  PacketEntity _draft = PacketEntity();
  // Selection state for packet selection sheet
  Set<int> _selectedIds = {};
  Map<int, int> _qtys = {};
}
