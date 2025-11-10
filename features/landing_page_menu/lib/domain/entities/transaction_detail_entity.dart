import 'package:landing_page_menu/domain/entities/product_entity.dart';
import 'package:landing_page_menu/data/models/transaction_detail_model.dart';

class TransactionDetailEntity {
  final int? id;
  final int? idServer;
  final int transactionId;
  final int productId;
  final String productName;
  final int productPrice;
  final int qty;
  final int subtotal;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  // Relasi sebagai Entity
  final ProductEntity? product;

  const TransactionDetailEntity({
    this.id,
    this.idServer,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.qty,
    required this.subtotal,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
    this.product,
  });

  TransactionDetailEntity copyWith({
    int? id,
    int? idServer,
    int? transactionId,
    int? productId,
    String? productName,
    int? productPrice,
    int? qty,
    int? subtotal,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    ProductEntity? product,
  }) {
    return TransactionDetailEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      product: product ?? this.product,
    );
  }

  factory TransactionDetailEntity.fromModel(TransactionDetailModel model) {
    return TransactionDetailEntity(
      id: model.id,
      idServer: model.idServer,
      transactionId: model.transactionId,
      productId: model.productId,
      productName: model.productName,
      productPrice: model.productPrice,
      qty: model.qty,
      subtotal: model.subtotal,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncedAt: model.syncedAt,
      product: model.product?.toEntity(),
    );
  }

  TransactionDetailModel toModel() {
    return TransactionDetailModel(
      id: id,
      idServer: idServer,
      transactionId: transactionId,
      productId: productId,
      productName: productName,
      productPrice: productPrice,
      qty: qty,
      subtotal: subtotal,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
      product: product?.toModel(),
    );
  }

  List<Object?> get props => [
        id,
        idServer,
        transactionId,
        productId,
        productName,
        productPrice,
        qty,
        subtotal,
        deletedAt?.millisecondsSinceEpoch,
        createdAt?.millisecondsSinceEpoch,
        updatedAt?.millisecondsSinceEpoch,
        syncedAt?.millisecondsSinceEpoch,
        product,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionDetailEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.transactionId == transactionId &&
        other.productId == productId &&
        other.productName == productName &&
        other.productPrice == productPrice &&
        other.qty == qty &&
        other.subtotal == subtotal &&
        other.deletedAt?.millisecondsSinceEpoch ==
            deletedAt?.millisecondsSinceEpoch &&
        other.createdAt?.millisecondsSinceEpoch ==
            createdAt?.millisecondsSinceEpoch &&
        other.updatedAt?.millisecondsSinceEpoch ==
            updatedAt?.millisecondsSinceEpoch &&
        other.syncedAt?.millisecondsSinceEpoch ==
            syncedAt?.millisecondsSinceEpoch &&
        other.product == product;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      idServer,
      transactionId,
      productId,
      productName,
      productPrice,
      qty,
      subtotal,
      deletedAt?.millisecondsSinceEpoch,
      createdAt?.millisecondsSinceEpoch,
      updatedAt?.millisecondsSinceEpoch,
      syncedAt?.millisecondsSinceEpoch,
      product,
    ]);
  }
}
