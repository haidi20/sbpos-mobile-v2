import 'package:transaction/data/models/transaction_detail.model.dart';
import 'package:transaction/domain/entitties/transaction_status.dart';

class TransactionModel {
  final int? id;
  final int? idServer;
  final int? shiftId;
  final int? warehouseId;
  final int? sequenceNumber;
  final int? orderTypeId;
  final String? categoryOrder;
  final int? userId;
  final String? paymentMethod;
  final DateTime? date;
  final String? notes;
  final int? totalAmount;
  final int? totalQty;
  final int? paidAmount;
  final int? changeMoney;
  final TransactionStatus? status;
  final String? cancelationOtp;
  final String? cancelationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  final List<TransactionDetailModel>? details;

  TransactionModel({
    this.id,
    this.idServer,
    this.shiftId,
    this.warehouseId,
    this.sequenceNumber,
    this.orderTypeId,
    this.categoryOrder,
    this.userId,
    this.paymentMethod,
    this.date,
    this.notes,
    this.totalAmount,
    this.totalQty,
    this.paidAmount,
    this.changeMoney,
    this.status,
    this.cancelationOtp,
    this.cancelationReason,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncedAt,
    this.details,
  });

  TransactionModel copyWith({
    int? id,
    int? idServer,
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
    TransactionStatus? status,
    String? cancelationOtp,
    String? cancelationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? syncedAt,
    List<TransactionDetailModel>? details,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
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
      status: status ?? this.status,
      cancelationOtp: cancelationOtp ?? this.cancelationOtp,
      cancelationReason: cancelationReason ?? this.cancelationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      details: details ?? this.details,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        idServer: _toInt(json['id']),
        shiftId: _toInt(json['shift_id']),
        warehouseId: _toInt(json['warehouse_id']),
        sequenceNumber: _toInt(json['sequence_number']),
        orderTypeId: _toInt(json['order_type_id']),
        categoryOrder: json['category_order'],
        userId: _toInt(json['user_id']),
        paymentMethod: json['payment_method'],
        date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
        notes: json['notes'],
        totalAmount: _toInt(json['total_amount']),
        totalQty: _toInt(json['total_qty']),
        paidAmount: _toInt(json['paid_amount']),
        changeMoney: _toInt(json['change_money']),
        status: _statusFromString(json['status'] as String?),
        cancelationOtp: json['cancelation_otp'],
        cancelationReason: json['cancelation_reason'],
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
        details: json['details'] != null
            ? List<TransactionDetailModel>.from((json['details'] as List)
                .map((e) => TransactionDetailModel.fromJson(e)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_server': idServer,
        'shift_id': shiftId,
        'warehouse_id': warehouseId,
        'sequence_number': sequenceNumber,
        'order_type_id': orderTypeId,
        'category_order': categoryOrder,
        'user_id': userId,
        'payment_method': paymentMethod,
        'date': date?.toIso8601String(),
        'notes': notes,
        'total_amount': totalAmount,
        'total_qty': totalQty,
        'paid_amount': paidAmount,
        // DB migration expects change_money NOT NULL DEFAULT 0
        'change_money': changeMoney ?? 0,
        // store enum as string for DB/JSON
        'status': _statusToString(status) ?? 'Pending',
        'cancelation_otp': cancelationOtp,
        'cancelation_reason': cancelationReason,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
        'details': details?.map((e) => e.toJson()).toList(),
      };

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer,
        'shift_id': shiftId,
        'warehouse_id': warehouseId,
        'sequence_number': sequenceNumber,
        'order_type_id': orderTypeId,
        'category_order': categoryOrder,
        'user_id': userId,
        'payment_method': paymentMethod,
        'date': date?.toIso8601String(),
        'notes': notes,
        'total_amount': totalAmount,
        'total_qty': totalQty,
        'paid_amount': paidAmount,
        // ensure DB non-null default
        'change_money': changeMoney ?? 0,
        // store enum as string
        'status': _statusToString(status) ?? 'Pending',
        'cancelation_otp': cancelationOtp,
        'cancelation_reason': cancelationReason,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  // Conversion to domain entity is provided by `TransactionEntity.fromModel` to
  // avoid circular imports. Use that constructor where needed.

  factory TransactionModel.fromDbLocal(Map<String, dynamic> map) {
    return TransactionModel(
      id: _toInt(map['id']),
      idServer: _toInt(map['id_server']),
      shiftId: _toInt(map['shift_id']),
      warehouseId: _toInt(map['warehouse_id']),
      sequenceNumber: _toInt(map['sequence_number']),
      orderTypeId: _toInt(map['order_type_id']),
      categoryOrder: map['category_order'] as String?,
      userId: _toInt(map['user_id']),
      paymentMethod: map['payment_method'] as String?,
      date: _toDate(map['date']),
      notes: map['notes'] as String?,
      // migration defines total_amount and total_qty as NOT NULL
      totalAmount: _toInt(map['total_amount']) ?? 0,
      totalQty: _toInt(map['total_qty']) ?? 0,
      paidAmount: _toInt(map['paid_amount']),
      // ensure changeMoney defaults to 0
      changeMoney: _toInt(map['change_money']) ?? 0,
      // parse stored status string into enum, default to Pending
      status: _statusFromString(map['status'] as String?),
      cancelationOtp: map['cancelation_otp'] as String?,
      cancelationReason: map['cancelation_reason'] as String?,
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
      deletedAt: _toDate(map['deleted_at']),
      syncedAt: _toDate(map['synced_at']),
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

  // Helpers to convert status between stored string and enum
  static TransactionStatus? _statusFromString(String? s) {
    switch (s) {
      case 'Lunas':
        return TransactionStatus.lunas;
      case 'Pending':
        return TransactionStatus.pending;
      case 'Batal':
        return TransactionStatus.batal;
      default:
        return TransactionStatus.unknown;
    }
  }

  static String? _statusToString(TransactionStatus? status) {
    if (status == null) return null;
    switch (status) {
      case TransactionStatus.lunas:
        return 'Lunas';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.batal:
        return 'Batal';
      default:
        return '';
    }
  }
}
