import 'package:landing_page_menu/data/models/product_model.dart';
import 'package:landing_page_menu/domain/entities/transaction_detail_entity.dart';

class TransactionDetailModel {
  final int? id;
  final int? idServer;
  final int transactionId;
  final int productId;
  final String productName;
  final int productPrice; // dalam satuan terkecil (misal: rupiah)
  final int qty;
  final int subtotal;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  // Relasi opsional (jika API mengembalikan nested data)
  final ProductModel? product;

  TransactionDetailModel({
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

  TransactionDetailModel copyWith({
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
    ProductModel? product,
  }) {
    return TransactionDetailModel(
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

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
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

    return TransactionDetailModel(
      id: parseInt(json['id']),
      idServer: parseInt(json['id']) ?? parseInt(json['id_server']),
      transactionId: parseInt(json['transaction_id']) ?? 0,
      productId: parseInt(json['product_id']) ?? 0,
      productName: json['product_name'] as String? ?? '',
      productPrice: parseInt(json['product_price']) ?? 0,
      qty: parseInt(json['qty']) ?? 0,
      subtotal: parseInt(json['subtotal']) ?? 0,
      deletedAt: parseDate(json['deleted_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      syncedAt: parseDate(json['synced_at']),
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_server': idServer,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'qty': qty,
      'subtotal': subtotal,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'product': product?.toJson(),
    };
  }

  TransactionDetailEntity toEntity() {
    return TransactionDetailEntity(
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
      product: product?.toEntity(),
    );
  }

  factory TransactionDetailModel.fromEntity(TransactionDetailEntity entity) {
    return TransactionDetailModel(
      id: entity.id,
      idServer: entity.idServer,
      transactionId: entity.transactionId,
      productId: entity.productId,
      productName: entity.productName,
      productPrice: entity.productPrice,
      qty: entity.qty,
      subtotal: entity.subtotal,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncedAt: entity.syncedAt,
      product: entity.product?.toModel(),
    );
  }

  // Untuk database lokal (Sqflite) — tanpa objek nested
  factory TransactionDetailModel.fromDbLocal(Map<String, dynamic> map) {
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

    return TransactionDetailModel(
      id: toInt(map['id']),
      idServer: toInt(map['id_server']),
      transactionId: toInt(map['transaction_id']) ?? 0,
      productId: toInt(map['product_id']) ?? 0,
      productName: map['product_name'] as String? ?? '',
      productPrice: toInt(map['product_price']) ?? 0,
      qty: toInt(map['qty']) ?? 0,
      subtotal: toInt(map['subtotal']) ?? 0,
      deletedAt: toDate(map['deleted_at']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      syncedAt: toDate(map['synced_at']),
      product: null, // tidak simpan relasi di lokal
    );
  }

  Map<String, dynamic> toDbLocal() {
    return {
      'id': id,
      'id_server': idServer,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'qty': qty,
      'subtotal': subtotal,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }
}
