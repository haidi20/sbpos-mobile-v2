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
  })  : _getPacketsUsecase = getPacketsUsecase,
        _createPacketUsecase = createPacketUsecase,
        _updatePacketUsecase = updatePacketUsecase,
        _deletePacketUsecase = deletePacketUsecase,
        super(PacketManagementState());

  final GetPackets _getPacketsUsecase;
  final CreatePacket _createPacketUsecase;
  final UpdatePacket _updatePacketUsecase;
  final DeletePacket _deletePacketUsecase;
  // final _logger = Logger('PacketManagementViewModel');

  PacketEntity _draft = PacketEntity();
  PacketEntity get draft => _draft;

  // Selection state for packet selection sheet
  Set<int> _selectedIds = {};
  Map<int, int> _qtys = {};

  /// Initialize selection state from a packet's items.
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

  void toggleSelected(int productId) {
    if (_selectedIds.contains(productId)) {
      _selectedIds.remove(productId);
    } else {
      _selectedIds.add(productId);
      _qtys.putIfAbsent(productId, () => 1);
    }
    state = state.copyWith(loading: state.loading);
  }

  int qtyFor(int productId, [int fallback = 1]) => _qtys[productId] ?? fallback;

  void incrementQty(int productId) {
    final current = _qtys[productId] ?? 1;
    _qtys[productId] = (current + 1).clamp(1, 999).toInt();
    state = state.copyWith(loading: state.loading);
  }

  void decrementQty(int productId) {
    final current = _qtys[productId] ?? 1;
    _qtys[productId] = (current - 1).clamp(1, 999).toInt();
    state = state.copyWith(loading: state.loading);
  }

  /// Returns an immutable view of selected ids and their quantities.
  Map<int, int> get selectedMap => Map<int, int>.unmodifiable(_qtys);

  /// Immutable view of selected product ids.
  Set<int> get selectedIds => Set<int>.unmodifiable(_selectedIds);

  void setIsForm(bool v) => state = state.copyWith(isForm: v);
  void setDraft(PacketEntity p) => _draft = p;
  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  // Draft item management
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
        }
        return ok;
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}
