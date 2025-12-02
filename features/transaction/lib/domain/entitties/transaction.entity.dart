import 'package:transaction/data/models/transaction_model.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

enum TransactionStatus { lunas, pending, batal, unknown }

class TransactionEntity {
  final int? id;
  final int? shiftId;
  final int warehouseId;
  final int sequenceNumber;
  final int orderTypeId;
  final String? categoryOrder;
  final int? userId;
  final String? paymentMethod;
  final DateTime date;
  final String? notes;
  final int totalAmount;
  final int totalQty;
  final int? paidAmount;
  final int changeMoney;
  final TransactionStatus status;
  final String? cancelationOtp;
  final String? cancelationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<TransactionDetailEntity>? details;

  const TransactionEntity({
    this.id,
    this.shiftId,
    required this.warehouseId,
    required this.sequenceNumber,
    required this.orderTypeId,
    this.categoryOrder,
    this.userId,
    this.paymentMethod,
    required this.date,
    this.notes,
    required this.totalAmount,
    required this.totalQty,
    this.paidAmount,
    this.changeMoney = 0,
    this.status = TransactionStatus.pending,
    this.cancelationOtp,
    this.cancelationReason,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.details,
  });

  TransactionEntity copyWith({
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
    TransactionStatus? status,
    String? cancelationOtp,
    String? cancelationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<TransactionDetailEntity>? details,
  }) {
    return TransactionEntity(
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
      status: status ?? this.status,
      cancelationOtp: cancelationOtp ?? this.cancelationOtp,
      cancelationReason: cancelationReason ?? this.cancelationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      details: details ?? this.details,
    );
  }

  factory TransactionEntity.fromModel(TransactionModel model) {
    return TransactionEntity(
      id: model.id,
      shiftId: model.shiftId,
      warehouseId: model.warehouseId!,
      sequenceNumber: model.sequenceNumber!,
      orderTypeId: model.orderTypeId!,
      categoryOrder: model.categoryOrder,
      userId: model.userId,
      paymentMethod: model.paymentMethod,
      date: model.date!,
      notes: model.notes,
      totalAmount: model.totalAmount!,
      totalQty: model.totalQty!,
      paidAmount: model.paidAmount,
      changeMoney: model.changeMoney ?? 0,
      status: _statusFromString(model.status),
      cancelationOtp: model.cancelationOtp,
      cancelationReason: model.cancelationReason,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
      details: model.details
          ?.map((m) => TransactionDetailEntity.fromModel(m))
          .toList(),
    );
  }

  TransactionModel toModel() {
    return TransactionModel(
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
      status: _statusToString(status),
      cancelationOtp: cancelationOtp,
      cancelationReason: cancelationReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      details: details?.map((d) => d.toModel()).toList(),
    );
  }

  static TransactionStatus _statusFromString(String? status) {
    switch (status) {
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

  static String _statusToString(TransactionStatus status) {
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity &&
        other.id == id &&
        other.shiftId == shiftId &&
        other.warehouseId == warehouseId &&
        other.sequenceNumber == sequenceNumber &&
        other.orderTypeId == orderTypeId &&
        other.categoryOrder == categoryOrder &&
        other.userId == userId &&
        other.paymentMethod == paymentMethod &&
        other.date == date &&
        other.notes == notes &&
        other.totalAmount == totalAmount &&
        other.totalQty == totalQty &&
        other.paidAmount == paidAmount &&
        other.changeMoney == changeMoney &&
        other.status == status &&
        other.cancelationOtp == cancelationOtp &&
        other.cancelationReason == cancelationReason &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        shiftId,
        warehouseId,
        sequenceNumber,
        orderTypeId,
        categoryOrder,
        userId,
        paymentMethod,
        date,
        notes,
        totalAmount,
        totalQty,
        paidAmount,
        changeMoney,
        status,
        cancelationOtp,
        cancelationReason,
        createdAt,
        updatedAt,
        deletedAt,
      );

  @override
  String toString() {
    return 'TransactionEntity(id: $id, shiftId: $shiftId, warehouseId: $warehouseId, sequenceNumber: $sequenceNumber, orderTypeId: $orderTypeId, categoryOrder: $categoryOrder, userId: $userId, paymentMethod: $paymentMethod, date: $date, notes: $notes, totalAmount: $totalAmount, totalQty: $totalQty, paidAmount: $paidAmount, changeMoney: $changeMoney, status: $status, cancelationOtp: $cancelationOtp, cancelationReason: $cancelationReason, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, details: $details)';
  }
}
