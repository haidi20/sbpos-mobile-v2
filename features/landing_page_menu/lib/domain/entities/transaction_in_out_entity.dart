import 'package:core/domain/entities/user_entity.dart';
import 'package:landing_page_menu/data/models/transaction_in_out_model.dart';
import 'package:landing_page_menu/domain/entities/transaction_entity.dart';
import 'package:warehouse/domain/entities/warehouse_entity.dart';

class TransactionInOutEntity {
  final int? id;
  final int? idServer;
  final int warehouseId;
  final int ingredientId;
  final int qty;
  final DateTime date;
  final String transactionType; // 'in' atau 'out'
  final int? userId;
  final int? transactionId;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  // Relasi sebagai Entity
  final WarehouseEntity? warehouse;
  // final IngredientEntity? ingredient;
  final UserEntity? user;
  final TransactionEntity? transaction;

  const TransactionInOutEntity({
    this.id,
    this.idServer,
    required this.warehouseId,
    required this.ingredientId,
    required this.qty,
    required this.date,
    required this.transactionType,
    this.userId,
    this.transactionId,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
    this.warehouse,
    // this.ingredient,
    this.user,
    this.transaction,
  });

  TransactionInOutEntity copyWith({
    int? id,
    int? idServer,
    int? warehouseId,
    int? ingredientId,
    int? qty,
    DateTime? date,
    String? transactionType,
    int? userId,
    int? transactionId,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    WarehouseEntity? warehouse,
    // IngredientEntity? ingredient,
    UserEntity? user,
    TransactionEntity? transaction,
  }) {
    return TransactionInOutEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      warehouseId: warehouseId ?? this.warehouseId,
      ingredientId: ingredientId ?? this.ingredientId,
      qty: qty ?? this.qty,
      date: date ?? this.date,
      transactionType: transactionType ?? this.transactionType,
      userId: userId ?? this.userId,
      transactionId: transactionId ?? this.transactionId,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      warehouse: warehouse ?? this.warehouse,
      // ingredient: ingredient ?? this.ingredient,
      user: user ?? this.user,
      transaction: transaction ?? this.transaction,
    );
  }

  factory TransactionInOutEntity.fromModel(TransactionInOutModel model) {
    return TransactionInOutEntity(
      id: model.id,
      idServer: model.idServer,
      warehouseId: model.warehouseId,
      ingredientId: model.ingredientId,
      qty: model.qty,
      date: model.date,
      transactionType: model.transactionType,
      userId: model.userId,
      transactionId: model.transactionId,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncedAt: model.syncedAt,
      warehouse: model.warehouse?.toEntity(),
      // ingredient: model.ingredient?.toEntity(),
      user: model.user?.toEntity(),
      transaction: model.transaction?.toEntity(),
    );
  }

  TransactionInOutModel toModel() {
    return TransactionInOutModel(
      id: id,
      idServer: idServer,
      warehouseId: warehouseId,
      ingredientId: ingredientId,
      qty: qty,
      date: date,
      transactionType: transactionType,
      userId: userId,
      transactionId: transactionId,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
      warehouse: warehouse?.toModel(),
      // ingredient: ingredient?.toModel(),
      user: user?.toModel(),
      transaction: transaction?.toModel(),
    );
  }

  List<Object?> get props => [
        id,
        idServer,
        warehouseId,
        ingredientId,
        qty,
        date.millisecondsSinceEpoch,
        transactionType,
        userId,
        transactionId,
        deletedAt?.millisecondsSinceEpoch,
        createdAt?.millisecondsSinceEpoch,
        updatedAt?.millisecondsSinceEpoch,
        syncedAt?.millisecondsSinceEpoch,
        warehouse,
        // ingredient,
        user,
        transaction,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionInOutEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.warehouseId == warehouseId &&
        other.ingredientId == ingredientId &&
        other.qty == qty &&
        other.date.millisecondsSinceEpoch == date.millisecondsSinceEpoch &&
        other.transactionType == transactionType &&
        other.userId == userId &&
        other.transactionId == transactionId &&
        other.deletedAt?.millisecondsSinceEpoch ==
            deletedAt?.millisecondsSinceEpoch &&
        other.createdAt?.millisecondsSinceEpoch ==
            createdAt?.millisecondsSinceEpoch &&
        other.updatedAt?.millisecondsSinceEpoch ==
            updatedAt?.millisecondsSinceEpoch &&
        other.syncedAt?.millisecondsSinceEpoch ==
            syncedAt?.millisecondsSinceEpoch &&
        other.warehouse == warehouse &&
        // other.ingredient == ingredient &&
        other.user == user &&
        other.transaction == transaction;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      idServer,
      warehouseId,
      ingredientId,
      qty,
      date.millisecondsSinceEpoch,
      transactionType,
      userId,
      transactionId,
      deletedAt?.millisecondsSinceEpoch,
      createdAt?.millisecondsSinceEpoch,
      updatedAt?.millisecondsSinceEpoch,
      syncedAt?.millisecondsSinceEpoch,
      warehouse,
      // ingredient,
      user,
      transaction,
    ]);
  }
}
