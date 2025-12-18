// Entitas domain untuk detail transaksi

import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';

class TransactionDetailEntity {
  final int? id;
  final int? transactionId;
  final int? productId;
  final String? productName;
  final int? productPrice;
  final int? packetId;
  final String? packetName;
  final int? packetPrice;
  final int? qty;
  final int? subtotal;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? note;

  const TransactionDetailEntity({
    this.id,
    this.transactionId,
    this.productId,
    this.productName,
    this.productPrice,
    this.packetId,
    this.packetName,
    this.packetPrice,
    this.qty,
    this.subtotal,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.note,
  });

  TransactionDetailEntity copyWith({
    int? id,
    int? transactionId,
    int? productId,
    String? productName,
    int? productPrice,
    int? packetId,
    String? packetName,
    int? packetPrice,
    int? qty,
    int? subtotal,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? note,
  }) {
    return TransactionDetailEntity(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      packetId: packetId ?? this.packetId,
      packetName: packetName ?? this.packetName,
      packetPrice: packetPrice ?? this.packetPrice,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      note: note ?? this.note,
    );
  }

  factory TransactionDetailEntity.fromModel(TransactionDetailModel model) {
    return TransactionDetailEntity(
      id: model.id,
      transactionId: model.transactionId,
      productId: model.productId,
      productName: model.productName,
      productPrice: model.productPrice,
      packetId: model.packetId,
      packetName: model.packetName,
      packetPrice: model.packetPrice,
      qty: model.qty,
      subtotal: model.subtotal,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
      note: model.note,
    );
  }

  TransactionDetailModel toModel() {
    return TransactionDetailModel(
      id: id,
      transactionId: transactionId,
      productId: productId,
      productName: productName,
      productPrice: productPrice,
      packetId: packetId,
      packetName: packetName,
      packetPrice: packetPrice,
      qty: qty,
      subtotal: subtotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      note: note,
    );
  }

  /// Buat `TransactionDetailEntity` dari `ProductEntity`
  factory TransactionDetailEntity.fromProductEntity({
    required int transactionId,
    required ProductEntity product,
    int? qty,
    String? note,
    // Optional packet fields to allow creating packet-backed details
    int? packetId,
    String? packetName,
    int? packetPrice,
  }) {
    // Peta (map) field produk ke detail transaksi, pertahankan nilai null
    // jika data produk tidak tersedia. `subtotal` akan null jika `productPrice`
    // null supaya tidak otomatis menjadi nol.
    final int? productPrice = product.price?.toInt();
    // Prioritaskan argumen `qty` jika diberikan; jika tidak, gunakan
    // `product.qty` bila tersedia; bila keduanya tidak ada, gunakan 1.
    final int effectiveQty = qty ?? product.qty?.toInt() ?? 1;

    // Hitung subtotal hanya jika productPrice tersedia.
    final int? subtotal =
        productPrice != null ? productPrice * effectiveQty : null;

    return TransactionDetailEntity(
      transactionId: transactionId,
      productId: product.id,
      productName: product.name,
      productPrice: productPrice,
      packetId: packetId,
      packetName: packetName,
      packetPrice: packetPrice,
      qty: effectiveQty,
      subtotal: subtotal,
      note: note ?? product.productDetails,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      deletedAt: product.deletedAt,
    );
  }

  /// Konversi detail ini menjadi `ProductEntity` minimal
  ProductEntity toProductEntity() {
    return ProductEntity(
      id: productId,
      name: productName,
      price: productPrice?.toDouble(),
      qty: qty?.toDouble(),
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      productDetails: note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionDetailEntity &&
        other.id == id &&
        other.transactionId == transactionId &&
        other.productId == productId &&
        other.productName == productName &&
        other.productPrice == productPrice &&
        other.qty == qty &&
        other.subtotal == subtotal &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.note == note;
  }

  @override
  int get hashCode => Object.hash(
        id,
        transactionId,
        productId,
        productName,
        productPrice,
        qty,
        subtotal,
        createdAt,
        updatedAt,
        deletedAt,
        note,
      );

  @override
  String toString() {
    return 'TransactionDetailEntity('
        'id: $id, '
        'transactionId: $transactionId, '
        'productId: $productId, '
        'productName: $productName, '
        'productPrice: $productPrice, '
        'qty: $qty, '
        'subtotal: $subtotal, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'deletedAt: $deletedAt, '
        'note: $note'
        ')';
  }
}
