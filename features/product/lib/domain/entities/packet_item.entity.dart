class PacketItemEntity {
  final int? id;
  final int? packetId;
  final int? productId;
  final int? qty;
  final int? subtotal; // optional override
  final int? discount; // per-item discount in currency (integer)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PacketItemEntity({
    this.id,
    this.packetId,
    this.productId,
    this.qty,
    this.subtotal,
    this.discount,
    this.createdAt,
    this.updatedAt,
  });

  PacketItemEntity copyWith({
    int? id,
    int? packetId,
    int? productId,
    int? qty,
    int? subtotal,
    int? discount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PacketItemEntity(
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
}
