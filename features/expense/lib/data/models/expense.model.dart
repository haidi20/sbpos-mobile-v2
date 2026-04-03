import 'package:expense/domain/entities/expense.entity.dart';

class ExpenseModel {
  final int? id;
  final int? idServer;
  final int? categoryId;
  final String? categoryName;
  final int? qty;
  final int? totalAmount;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? syncedAt;

  const ExpenseModel({
    this.id,
    this.idServer,
    this.categoryId,
    this.categoryName,
    this.qty,
    this.totalAmount,
    this.notes,
    this.createdAt,
    this.syncedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: _toInt(json['id']),
      idServer: _toInt(json['id_server']),
      categoryId: _toInt(json['category_id']),
      categoryName: json['category_name'] as String?,
      qty: _toInt(json['qty']),
      totalAmount: _toInt(json['total_amount']),
      notes: json['notes'] as String?,
      createdAt: _toDate(json['created_at']),
      syncedAt: _toDate(json['synced_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_server': idServer,
      'category_id': categoryId,
      'category_name': categoryName,
      'qty': qty,
      'total_amount': totalAmount,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertDbLocal() {
    return {
      'id': null, // Auto-increment
      'id_server': idServer,
      'category_id': categoryId,
      'category_name': categoryName,
      'qty': qty,
      'total_amount': totalAmount,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory ExpenseModel.fromDbLocal(Map<String, dynamic> map) {
    return ExpenseModel(
      id: _toInt(map['id']),
      idServer: _toInt(map['id_server']),
      categoryId: _toInt(map['category_id']),
      categoryName: map['category_name'] as String?,
      qty: _toInt(map['qty']),
      totalAmount: _toInt(map['total_amount']),
      notes: map['notes'] as String?,
      createdAt: _toDate(map['created_at']),
      syncedAt: _toDate(map['synced_at']),
    );
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      qty: entity.qty,
      totalAmount: entity.totalAmount,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      qty: qty,
      totalAmount: totalAmount,
      notes: notes,
      createdAt: createdAt,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
