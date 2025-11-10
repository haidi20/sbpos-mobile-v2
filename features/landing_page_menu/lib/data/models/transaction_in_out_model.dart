import 'package:core/data/models/user_model.dart';
import 'package:warehouse/data/models/warehouse_model.dart';
import 'package:landing_page_menu/data/models/transaction_model.dart';
import 'package:landing_page_menu/domain/entities/transaction_in_out_entity.dart';

class TransactionInOutModel {
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

  // Relasi opsional (jika API mengembalikan nested object)
  final WarehouseModel? warehouse;
  // final IngredientModel? ingredient;
  final UserModel? user;
  final TransactionModel? transaction;

  TransactionInOutModel({
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

  TransactionInOutModel copyWith({
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
    WarehouseModel? warehouse,
    // IngredientModel? ingredient,
    UserModel? user,
    TransactionModel? transaction,
  }) {
    return TransactionInOutModel(
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

  factory TransactionInOutModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    String? parseString(dynamic value) => value is String ? value : null;

    return TransactionInOutModel(
      id: parseInt(json['id']),
      idServer: parseInt(json['id']) ?? parseInt(json['id_server']),
      warehouseId: parseInt(json['warehouse_id']) ?? 0,
      ingredientId: parseInt(json['ingredient_id']) ?? 0,
      qty: parseInt(json['qty']) ?? 0,
      date: parseDate(json['date']) ?? DateTime.now(),
      transactionType: parseString(json['transaction_type']) ?? 'in',
      userId: parseInt(json['user_id']),
      transactionId: parseInt(json['transaction_id']),
      deletedAt: parseDate(json['deleted_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      syncedAt: parseDate(json['synced_at']),
      warehouse: json['warehouse'] != null
          ? WarehouseModel.fromJson(json['warehouse'] as Map<String, dynamic>)
          : null,
      // ingredient: json['ingredient'] != null
      //     ? IngredientModel.fromJson(json['ingredient'] as Map<String, dynamic>)
      //     : null,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      transaction: json['transaction'] != null
          ? TransactionModel.fromJson(
              json['transaction'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_server': idServer,
      'warehouse_id': warehouseId,
      'ingredient_id': ingredientId,
      'qty': qty,
      'date': date.toIso8601String(),
      'transaction_type': transactionType,
      'user_id': userId,
      'transaction_id': transactionId,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'warehouse': warehouse?.toJson(),
      // 'ingredient': ingredient?.toJson(),
      'user': user?.toJson(),
      'transaction': transaction?.toJson(),
    };
  }

  TransactionInOutEntity toEntity() {
    return TransactionInOutEntity(
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
      warehouse: warehouse?.toEntity(),
      // ingredient: ingredient?.toEntity(),
      user: user?.toEntity(),
      transaction: transaction?.toEntity(),
    );
  }

  factory TransactionInOutModel.fromEntity(TransactionInOutEntity entity) {
    return TransactionInOutModel(
      id: entity.id,
      idServer: entity.idServer,
      warehouseId: entity.warehouseId,
      ingredientId: entity.ingredientId,
      qty: entity.qty,
      date: entity.date,
      transactionType: entity.transactionType,
      userId: entity.userId,
      transactionId: entity.transactionId,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncedAt: entity.syncedAt,
      warehouse: entity.warehouse?.toModel(),
      // ingredient: entity.ingredient?.toModel(),
      user: entity.user?.toModel(),
      transaction: entity.transaction?.toModel(),
    );
  }

  // Untuk database lokal — tanpa relasi nested
  factory TransactionInOutModel.fromDbLocal(Map<String, dynamic> map) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return TransactionInOutModel(
      id: toInt(map['id']),
      idServer: toInt(map['id_server']),
      warehouseId: toInt(map['warehouse_id']) ?? 0,
      ingredientId: toInt(map['ingredient_id']) ?? 0,
      qty: toInt(map['qty']) ?? 0,
      date: toDate(map['date']) ?? DateTime.now(),
      transactionType: map['transaction_type'] as String? ?? 'in',
      userId: toInt(map['user_id']),
      transactionId: toInt(map['transaction_id']),
      deletedAt: toDate(map['deleted_at']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      syncedAt: toDate(map['synced_at']),
      // Relasi tidak disimpan di lokal
      warehouse: null,
      // ingredient: null,
      user: null,
      transaction: null,
    );
  }

  Map<String, dynamic> toDbLocal() {
    return {
      'id': id,
      'id_server': idServer,
      'warehouse_id': warehouseId,
      'ingredient_id': ingredientId,
      'qty': qty,
      'date': date.toIso8601String(),
      'transaction_type': transactionType,
      'user_id': userId,
      'transaction_id': transactionId,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }
}
