// Domain entity for transaction detail

import 'package:transaction/data/models/transaction_detail.model.dart';

class TransactionDetailEntity {
  final int? id;
  final int? transactionId;
  final int? productId;
  final String? productName;
  final int? productPrice;
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
      qty: qty,
      subtotal: subtotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      note: note,
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
}
