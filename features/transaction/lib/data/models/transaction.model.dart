import 'package:transaction/data/models/transaction_detail.model.dart';
import 'package:customer/data/models/customer.model.dart';
import 'package:transaction/domain/entitties/transaction_status.extension.dart';

class TransactionModel {
  final int? id;
  final int? idServer;
  final int? shiftId;
  final int? outletId;
  final int? sequenceNumber;
  final int? orderTypeId;
  final String? categoryOrder;
  final int? userId;
  final int? customerId;
  final String? customerType;
  final CustomerModel? customerSelected;
  final String? paymentMethod;
  final int? numberTable;
  final DateTime? date;
  final String? notes;
  final int? totalAmount;
  final int? totalQty;
  final int? paidAmount;
  final int? changeMoney;
  final bool? isPaid;
  final TransactionStatus? status;
  final String? cancelationOtp;
  final String? cancelationReason;
  final String? ojolProvider;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  final List<TransactionDetailModel>? details;

  TransactionModel({
    this.id,
    this.idServer,
    this.shiftId,
    this.outletId,
    this.sequenceNumber,
    this.orderTypeId,
    this.categoryOrder,
    this.userId,
    this.customerId,
    this.customerType,
    this.customerSelected,
    this.paymentMethod,
    this.numberTable,
    this.date,
    this.notes,
    this.totalAmount,
    this.totalQty,
    this.paidAmount,
    this.changeMoney,
    this.isPaid,
    this.status,
    this.cancelationOtp,
    this.cancelationReason,
    this.ojolProvider,
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
    int? outletId,
    int? sequenceNumber,
    int? orderTypeId,
    String? categoryOrder,
    int? userId,
    int? customerId,
    String? customerType,
    CustomerModel? customerSelected,
    String? paymentMethod,
    int? numberTable,
    DateTime? date,
    String? notes,
    int? totalAmount,
    int? totalQty,
    int? paidAmount,
    int? changeMoney,
    bool? isPaid,
    TransactionStatus? status,
    String? cancelationOtp,
    String? cancelationReason,
    String? ojolProvider,
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
      outletId: outletId ?? this.outletId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      orderTypeId: orderTypeId ?? this.orderTypeId,
      categoryOrder: categoryOrder ?? this.categoryOrder,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      customerType: customerType ?? this.customerType,
      customerSelected: customerSelected ?? this.customerSelected,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      numberTable: numberTable ?? this.numberTable,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      totalQty: totalQty ?? this.totalQty,
      paidAmount: paidAmount ?? this.paidAmount,
      changeMoney: changeMoney ?? this.changeMoney,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      cancelationOtp: cancelationOtp ?? this.cancelationOtp,
      cancelationReason: cancelationReason ?? this.cancelationReason,
      ojolProvider: ojolProvider ?? this.ojolProvider,
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
        outletId: _toInt(json['warehouse_id']),
        sequenceNumber: _toInt(json['sequence_number']),
        orderTypeId: _toInt(json['order_type_id']),
        categoryOrder: json['category_order'],
        ojolProvider: json['ojol_provider'] as String?,
        userId: _toInt(json['user_id']),
        customerId: _toInt(json['customer_id']),
        customerType: json['customer_type'] as String?,
        customerSelected: (json['customer_selected'] is Map<String, dynamic>)
            ? CustomerModel.fromJson(
                json['customer_selected'] as Map<String, dynamic>)
            : null,
        paymentMethod: json['payment_method'],
        numberTable: _toInt(json['number_table']),
        date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
        notes: json['notes'],
        totalAmount: _toInt(json['total_amount']),
        totalQty: _toInt(json['total_qty']),
        paidAmount: _toInt(json['paid_amount']),
        changeMoney: _toInt(json['change_money']),
        isPaid: (json['is_paid'] != null)
            ? ((json['is_paid'] is int)
                ? (json['is_paid'] as int) == 1
                : (json['is_paid'].toString() == '1'))
            : null,
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
        'warehouse_id': outletId,
        'sequence_number': sequenceNumber,
        'order_type_id': orderTypeId,
        'category_order': categoryOrder,
        'ojol_provider': ojolProvider,
        'user_id': userId,
        'customer_id': customerId,
        'customer_type': customerType,
        'customer_selected': customerSelected?.toJson(),
        'payment_method': paymentMethod,
        'number_table': numberTable,
        'date': date?.toIso8601String(),
        'notes': notes,
        'total_amount': totalAmount,
        'total_qty': totalQty,
        'paid_amount': paidAmount,
        // DB migration expects change_money NOT NULL DEFAULT 0
        'change_money': changeMoney ?? 0,
        'is_paid': (isPaid == true) ? 1 : 0,
        // store enum as string for DB/JSON
        'status': _statusToString(status) ?? TransactionStatus.pending.value,
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
        'outlet_id': outletId,
        'sequence_number': sequenceNumber,
        'order_type_id': orderTypeId,
        'category_order': categoryOrder,
        'ojol_provider': ojolProvider,
        'user_id': userId,
        'customer_id': customerId,
        'customer_type': customerType,
        'payment_method': paymentMethod,
        'number_table': numberTable,
        'date': date?.toIso8601String(),
        'notes': notes,
        'total_amount': totalAmount,
        'total_qty': totalQty,
        'paid_amount': paidAmount,
        // ensure DB non-null default
        'change_money': changeMoney ?? 0,
        'is_paid': (isPaid == true) ? 1 : 0,
        // store enum as string (use enum value)
        'status': _statusToString(status) ?? TransactionStatus.pending.value,
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
      outletId: _toInt(map['outlet_id']),
      sequenceNumber: _toInt(map['sequence_number']),
      orderTypeId: _toInt(map['order_type_id']),
      categoryOrder: map['category_order'] as String?,
      userId: _toInt(map['user_id']),
      customerId: _toInt(map['customer_id']),
      customerType: map['customer_type'] as String?,
      paymentMethod: map['payment_method'] as String?,
      numberTable: _toInt(map['number_table']),
      date: _toDate(map['date']),
      notes: map['notes'] as String?,
      // migration defines total_amount and total_qty as NOT NULL
      totalAmount: _toInt(map['total_amount']) ?? 0,
      totalQty: _toInt(map['total_qty']) ?? 0,
      paidAmount: _toInt(map['paid_amount']),
      // ensure changeMoney defaults to 0
      changeMoney: _toInt(map['change_money']) ?? 0,
      // read is_paid as int -> bool
      isPaid: ((_toInt(map['is_paid']) ?? 0) == 1),
      // read ojol_provider from local db map
      ojolProvider: map['ojol_provider'] as String?,
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
    if (s == null) return TransactionStatus.unknown;
    final lower = s.toString().toLowerCase();
    switch (lower) {
      case 'lunas':
        return TransactionStatus.lunas;
      case 'pending':
        return TransactionStatus.pending;
      case 'proses':
        return TransactionStatus.proses;
      case 'batal':
        return TransactionStatus.batal;
      default:
        return TransactionStatus.unknown;
    }
  }

  static String? _statusToString(TransactionStatus? status) {
    if (status == null) return null;
    return status.value;
  }
}
