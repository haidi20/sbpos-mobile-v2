import 'package:product/domain/entities/packet_item.entity.dart';

class PacketItemModel {
  final int? id;
  final int? packetId;
  final int? productId;
  final int? qty;
  final int? subtotal;
  final int? discount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PacketItemModel({
    this.id,
    this.packetId,
    this.productId,
    this.qty,
    this.subtotal,
    this.discount,
    this.createdAt,
    this.updatedAt,
  });

  PacketItemModel copyWith({
    int? id,
    int? packetId,
    int? productId,
    int? qty,
    int? subtotal,
    int? discount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PacketItemModel(
      id: id ?? this.id,
      packetId: packetId ?? this.packetId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create model from domain/entity
  factory PacketItemModel.fromEntity(PacketItemEntity e) {
    return PacketItemModel(
      id: e.id,
      packetId: e.packetId,
      productId: e.productId,
      qty: e.qty,
      subtotal: e.subtotal,
      discount: e.discount,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  factory PacketItemModel.fromDbLocal(Map<String, dynamic> map) {
    return PacketItemModel(
      id: _toInt(map['id']),
      packetId: _toInt(map['packet_id']),
      productId: _toInt(map['product_id']),
      qty: _toInt(map['qty']),
      subtotal: _toInt(map['subtotal']),
      discount: _toInt(map['discount']),
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
    );
  }

  factory PacketItemModel.fromJson(Map<String, dynamic> json) {
    return PacketItemModel(
      id: _toInt(json['id']),
      packetId: _toInt(json['packet_id']),
      productId: _toInt(json['product_id']) ?? 0,
      qty: _toInt(json['qty']) ?? 1,
      subtotal: _toInt(json['subtotal']),
      discount: _toInt(json['discount']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'packet_id': packetId,
        'product_id': productId,
        'qty': qty,
        'subtotal': subtotal,
        'discount': discount,
      };

  PacketItemEntity toEntity() => PacketItemEntity(
        id: id,
        packetId: packetId,
        productId: productId,
        qty: qty,
        subtotal: subtotal,
        discount: discount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'packet_id': packetId,
        'product_id': productId,
        'qty': qty,
        'subtotal': subtotal,
        'discount': discount,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
