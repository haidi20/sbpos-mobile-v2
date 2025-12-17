import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class TransactionDetailModel {
  final int? id;
  final int? idServer;
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
  final DateTime? syncedAt;
  final String? note;

  TransactionDetailModel({
    this.id,
    this.idServer,
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
    this.syncedAt,
    this.note,
  });

  TransactionDetailModel copyWith({
    int? id,
    int? idServer,
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
    DateTime? syncedAt,
    String? note,
  }) {
    return TransactionDetailModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
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
      syncedAt: syncedAt ?? this.syncedAt,
      note: note ?? this.note,
    );
  }

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      idServer: json['id'],
      transactionId: json['transaction_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      productPrice: json['product_price'],
      packetId: json['packet_id'],
      packetName: json['packet_name'],
      packetPrice: json['packet_price'],
      qty: json['qty'],
      subtotal: json['subtotal'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
      syncedAt: json['synced_at'] != null
          ? DateTime.tryParse(json['synced_at'])
          : null,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_server': idServer,
        'transaction_id': transactionId,
        'product_id': productId,
        'product_name': productName,
        'product_price': productPrice,
        'packet_id': packetId,
        'packet_name': packetName,
        'packet_price': packetPrice,
        'qty': qty,
        'subtotal': subtotal,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
        'note': note,
      };

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer,
        'transaction_id': transactionId,
        'product_id': productId,
        'product_name': productName,
        'product_price': productPrice,
        'packet_id': packetId,
        'packet_name': packetName,
        'packet_price': packetPrice,
        'qty': qty,
        'subtotal': subtotal,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
        'note': note,
      };

  // Convert to domain entity
  TransactionDetailEntity toEntity() => TransactionDetailEntity.fromModel(this);

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
      transactionId: toInt(map['transaction_id']),
      productId: toInt(map['product_id']),
      productName: map['product_name'] as String?,
      productPrice: toInt(map['product_price']),
      packetId: toInt(map['packet_id']),
      packetName: map['packet_name'] as String?,
      packetPrice: toInt(map['packet_price']),
      qty: toInt(map['qty']),
      subtotal: toInt(map['subtotal']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      deletedAt: toDate(map['deleted_at']),
      syncedAt: toDate(map['synced_at']),
      note: map['note'] as String?,
    );
  }
}
