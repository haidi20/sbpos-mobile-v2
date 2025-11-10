import 'package:core/data/models/user_model.dart';
import 'package:warehouse/data/models/warehouse_model.dart';
import 'package:landing_page_menu/data/models/order_type_model.dart';
import 'package:landing_page_menu/domain/entities/transaction_entity.dart';

class TransactionModel {
  final int? id;
  final int? shiftId;
  final int warehouseId;
  final int? sequenceNumber;
  final int orderTypeId;
  final String? categoryOrder;
  final int userId;
  final String? paymentMethod;
  final DateTime date;
  final String? notes;
  final int totalAmount;
  final int totalQty;
  final int? paidAmount;
  final int changeMoney;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final WarehouseModel? warehouse;
  final UserModel? user;
  final OrderTypeModel? orderType;

  TransactionModel({
    this.id,
    this.shiftId,
    required this.warehouseId,
    this.sequenceNumber,
    required this.orderTypeId,
    this.categoryOrder,
    required this.userId,
    this.paymentMethod,
    required this.date,
    this.notes,
    required this.totalAmount,
    required this.totalQty,
    this.paidAmount,
    required this.changeMoney,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.warehouse,
    this.user,
    this.orderType,
  });

  TransactionModel copyWith({
    int? id,
    int? shiftId,
    int? warehouseId,
    int? sequenceNumber,
    int? orderTypeId,
    String? categoryOrder,
    int? userId,
    String? paymentMethod,
    DateTime? date,
    String? notes,
    int? totalAmount,
    int? totalQty,
    int? paidAmount,
    int? changeMoney,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    WarehouseModel? warehouse,
    UserModel? user,
    OrderTypeModel? orderType,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      warehouseId: warehouseId ?? this.warehouseId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      orderTypeId: orderTypeId ?? this.orderTypeId,
      categoryOrder: categoryOrder ?? this.categoryOrder,
      userId: userId ?? this.userId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      totalQty: totalQty ?? this.totalQty,
      paidAmount: paidAmount ?? this.paidAmount,
      changeMoney: changeMoney ?? this.changeMoney,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      warehouse: warehouse ?? this.warehouse,
      user: user ?? this.user,
      orderType: orderType ?? this.orderType,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
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

    return TransactionModel(
      id: parseInt(json['id']),
      shiftId: parseInt(json['shift_id']),
      warehouseId: parseInt(json['warehouse_id']) ?? 0,
      sequenceNumber: parseInt(json['sequence_number']),
      orderTypeId: parseInt(json['order_type_id']) ?? 0,
      categoryOrder: parseString(json['category_order']),
      userId: parseInt(json['user_id']) ?? 0,
      paymentMethod: parseString(json['payment_method']),
      date: parseDate(json['date']) ?? DateTime.now(),
      notes: parseString(json['notes']),
      totalAmount: parseInt(json['total_amount']) ?? 0,
      totalQty: parseInt(json['total_qty']) ?? 0,
      paidAmount: parseInt(json['paid_amount']),
      changeMoney: parseInt(json['change_money']) ?? 0,
      deletedAt: parseDate(json['deleted_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),

      // Nested objects (jika API mengembalikan)
      warehouse: json['warehouse'] != null
          ? WarehouseModel.fromJson(json['warehouse'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      orderType: json['order_type'] != null
          ? OrderTypeModel.fromJson(json['order_type'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shift_id': shiftId,
      'warehouse_id': warehouseId,
      'sequence_number': sequenceNumber,
      'order_type_id': orderTypeId,
      'category_order': categoryOrder,
      'user_id': userId,
      'payment_method': paymentMethod,
      'date': date.toIso8601String(),
      'notes': notes,
      'total_amount': totalAmount,
      'total_qty': totalQty,
      'paid_amount': paidAmount,
      'change_money': changeMoney,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'warehouse': warehouse?.toJson(),
      'user': user?.toJson(),
      'order_type': orderType?.toJson(),
    };
  }

  // Konversi ke Entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      shiftId: shiftId,
      warehouseId: warehouseId,
      sequenceNumber: sequenceNumber,
      orderTypeId: orderTypeId,
      categoryOrder: categoryOrder,
      userId: userId,
      paymentMethod: paymentMethod,
      date: date,
      notes: notes,
      totalAmount: totalAmount,
      totalQty: totalQty,
      paidAmount: paidAmount,
      changeMoney: changeMoney,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      warehouse: warehouse?.toEntity(),
      user: user?.toEntity(),
      orderType: orderType?.toEntity(),
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      shiftId: entity.shiftId,
      warehouseId: entity.warehouseId,
      sequenceNumber: entity.sequenceNumber,
      orderTypeId: entity.orderTypeId,
      categoryOrder: entity.categoryOrder,
      userId: entity.userId,
      paymentMethod: entity.paymentMethod,
      date: entity.date,
      notes: entity.notes,
      totalAmount: entity.totalAmount,
      totalQty: entity.totalQty,
      paidAmount: entity.paidAmount,
      changeMoney: entity.changeMoney,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      warehouse: entity.warehouse != null
          ? WarehouseModel.fromEntity(entity.warehouse!)
          : null,
      user: entity.user != null ? UserModel.fromEntity(entity.user!) : null,
      orderType: entity.orderType != null
          ? OrderTypeModel.fromEntity(entity.orderType!)
          : null,
    );
  }

  // Untuk database lokal (Sqflite) — tanpa objek nested
  factory TransactionModel.fromDbLocal(Map<String, dynamic> map) {
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

    return TransactionModel(
      id: toInt(map['id']),
      shiftId: toInt(map['shift_id']),
      warehouseId: toInt(map['warehouse_id']) ?? 0,
      sequenceNumber: toInt(map['sequence_number']),
      orderTypeId: toInt(map['order_type_id']) ?? 0,
      categoryOrder: map['category_order'] as String?,
      userId: toInt(map['user_id']) ?? 0,
      paymentMethod: map['payment_method'] as String?,
      date: toDate(map['date']) ?? DateTime.now(),
      notes: map['notes'] as String?,
      totalAmount: toInt(map['total_amount']) ?? 0,
      totalQty: toInt(map['total_qty']) ?? 0,
      paidAmount: toInt(map['paid_amount']),
      changeMoney: toInt(map['change_money']) ?? 0,
      deletedAt: toDate(map['deleted_at']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      // Relasi tidak disimpan lengkap di lokal → null
      warehouse: null,
      user: null,
      orderType: null,
    );
  }

  Map<String, dynamic> toDbLocal() {
    return {
      'id': id,
      'shift_id': shiftId,
      'warehouse_id': warehouseId,
      'sequence_number': sequenceNumber,
      'order_type_id': orderTypeId,
      'category_order': categoryOrder,
      'user_id': userId,
      'payment_method': paymentMethod,
      'date': date.toIso8601String(),
      'notes': notes,
      'total_amount': totalAmount,
      'total_qty': totalQty,
      'paid_amount': paidAmount,
      'change_money': changeMoney,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
