import 'package:intl/intl.dart';

class PacketItemEntity {
  final int? id;
  final int? packetId;
  final int? productId;
  final String? productName;
  final int? qty;
  final int? subtotal; // optional override
  final int? discount; // per-item discount in currency (integer)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PacketItemEntity({
    this.id,
    this.packetId,
    this.productName,
    this.productId,
    this.qty,
    this.subtotal,
    this.discount,
    this.createdAt,
    this.updatedAt,
  });

  // Computed getters for convenience in UI
  int get unitPrice =>
      (qty != null && (qty ?? 0) > 0) ? ((subtotal ?? 0) ~/ (qty ?? 1)) : 0;

  int get total => subtotal ?? 0;

  int get discountAmount => discount ?? 0;

  bool get hasDiscount => discountAmount > 0;

  String get displayLabel {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final qtyStr = '${qty ?? 0}x';
    final unitStr = fmt.format(unitPrice);
    final discountStr = hasDiscount ? ' (-${fmt.format(discountAmount)})' : '';
    return '$qtyStr • $unitStr$discountStr';
  }

  PacketItemEntity copyWith({
    int? id,
    int? packetId,
    int? productId,
    String? productName,
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
      productName: productName ?? this.productName,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
