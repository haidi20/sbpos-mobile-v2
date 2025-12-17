import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/data/models/packet_item.model.dart';

class PacketModel {
  final int? id;
  final int? idServer;
  final String? name;
  final int? price;
  final bool? isActive;
  final List<PacketItemModel>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  PacketModel({
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

  PacketModel copyWith({
    int? id,
    int? idServer,
    String? name,
    int? price,
    bool? isActive,
    List<PacketItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? syncedAt,
  }) {
    return PacketModel(
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

  factory PacketModel.fromJson(Map<String, dynamic> json) {
    return PacketModel(
      id: _toInt(json['id']),
      idServer: _toInt(json['id_server'] ?? json['id']),
      name: json['name'] as String?,
      price: _toInt(json['price']),
      isActive: _toBool(json['is_active']),
      items: (json['items'] as List<dynamic>?)
          ?.map((i) => PacketItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      deletedAt: _toDate(json['deleted_at']),
      syncedAt: _toDate(json['synced_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': idServer,
        'id_server': idServer,
        'name': name,
        'price': price,
        'is_active': isActive == null ? null : (isActive! ? 1 : 0),
        'items': items?.map((i) => i.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  factory PacketModel.fromDbLocal(Map<String, dynamic> map,
      {List<PacketItemModel>? items}) {
    return PacketModel(
      id: _toInt(map['id']),
      idServer: _toInt(map['id_server']),
      name: map['name'] as String?,
      price: _toInt(map['price']),
      isActive: _toBool(map['is_active']),
      items: items,
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
      deletedAt: _toDate(map['deleted_at']),
      syncedAt: _toDate(map['synced_at']),
    );
  }

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer,
        'name': name,
        'price': price,
        'is_active': isActive == null ? null : (isActive! ? 1 : 0),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  PacketEntity toEntity() => PacketEntity(
        id: id,
        idServer: idServer,
        name: name,
        price: price,
        isActive: isActive,
        items: items?.map((m) => m.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        syncedAt: syncedAt,
      );

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool? _toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return null;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
