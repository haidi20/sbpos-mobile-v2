import 'package:product/domain/entities/packet.entity.dart';

class PacketManagementState {
  PacketManagementState({
    this.loading = false,
    this.isForm = false,
    this.searchQuery = '',
    List<PacketEntity>? packets,
    this.error,
  }) : packets = packets ?? [];

  final bool loading;
  final bool isForm;
  final String searchQuery;
  final List<PacketEntity> packets;
  final String? error;

  PacketManagementState copyWith({
    bool? loading,
    bool? isForm,
    String? searchQuery,
    List<PacketEntity>? packets,
    String? error,
  }) {
    return PacketManagementState(
      loading: loading ?? this.loading,
      isForm: isForm ?? this.isForm,
      searchQuery: searchQuery ?? this.searchQuery,
      packets: packets ?? this.packets,
      error: error ?? this.error,
    );
  }
}
