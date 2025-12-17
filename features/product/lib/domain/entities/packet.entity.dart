import 'package:product/domain/entities/packet_item.entity.dart';

class PacketEntity {
  final int? id;
  final int? idServer;
  final String? name;
  final int? price;
  final bool? isActive;
  final List<PacketItemEntity>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  PacketEntity({
    this.id,
    this.idServer,
    this.name,
    this.price,
    this.isActive,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });

  PacketEntity copyWith({
    int? id,
    int? idServer,
    String? name,
    int? price,
    bool? isActive,
    List<PacketItemEntity>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? syncedAt,
  }) {
    return PacketEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
