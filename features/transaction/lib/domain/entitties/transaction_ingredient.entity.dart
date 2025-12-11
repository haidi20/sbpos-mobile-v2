import 'package:transaction/data/models/transaction_ingredient.model.dart';

class TransactionIngredientEntity {
  final int? id;
  final int? outletId;
  final int? transactionId;
  final int? ingredientId;
  final int? productId;
  final DateTime date;
  final int? qtySold;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const TransactionIngredientEntity({
    this.id,
    this.outletId,
    this.transactionId,
    this.ingredientId,
    this.productId,
    required this.date,
    this.qtySold,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  TransactionIngredientEntity copyWith({
    int? id,
    int? outletId,
    int? transactionId,
    int? ingredientId,
    int? productId,
    DateTime? date,
    int? qtySold,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TransactionIngredientEntity(
      id: id ?? this.id,
      outletId: outletId ?? this.outletId,
      transactionId: transactionId ?? this.transactionId,
      ingredientId: ingredientId ?? this.ingredientId,
      productId: productId ?? this.productId,
      date: date ?? this.date,
      qtySold: qtySold ?? this.qtySold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory TransactionIngredientEntity.fromModel(
      TransactionIngredientModel model) {
    return TransactionIngredientEntity(
      id: model.id,
      outletId: model.outletId,
      transactionId: model.transactionId,
      ingredientId: model.ingredientId,
      productId: model.productId,
      date: model.date ?? DateTime.now(),
      qtySold: model.qtySold,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
    );
  }

  TransactionIngredientModel toModel() {
    return TransactionIngredientModel(
      id: id,
      outletId: outletId,
      transactionId: transactionId,
      ingredientId: ingredientId,
      productId: productId,
      date: date,
      qtySold: qtySold,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionIngredientEntity &&
        other.id == id &&
        other.outletId == outletId &&
        other.transactionId == transactionId &&
        other.ingredientId == ingredientId &&
        other.productId == productId &&
        other.date == date &&
        other.qtySold == qtySold &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        outletId,
        transactionId,
        ingredientId,
        productId,
        date,
        qtySold,
        createdAt,
        updatedAt,
        deletedAt,
      );
}
