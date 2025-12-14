import 'package:flutter/material.dart';

import 'transaction_status.extension.dart';
export 'transaction_status.extension.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class TransactionEntity {
  final int? id;
  final int? idServer;
  final int? shiftId;
  final DateTime? syncedAt;
  final int outletId;
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
  final bool isPaid;
  final TransactionStatus status;
  final String? cancelationOtp;
  final String? cancelationReason;
  final String? ojolProvider;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<TransactionDetailEntity>? details;

  const TransactionEntity({
    this.id,
    this.idServer,
    this.shiftId,
    required this.outletId,
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
    this.isPaid = false,
    this.status = TransactionStatus.pending,
    this.cancelationOtp,
    this.cancelationReason,
    this.ojolProvider,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.details,
    this.syncedAt,
  });

  TransactionEntity copyWith({
    int? id,
    int? idServer,
    int? shiftId,
    int? outletId,
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
    bool? isPaid,
    TransactionStatus? status,
    String? cancelationOtp,
    String? cancelationReason,
    String? ojolProvider,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<TransactionDetailEntity>? details,
    DateTime? syncedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      shiftId: shiftId ?? this.shiftId,
      outletId: outletId ?? this.outletId,
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
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      cancelationOtp: cancelationOtp ?? this.cancelationOtp,
      cancelationReason: cancelationReason ?? this.cancelationReason,
      ojolProvider: ojolProvider ?? this.ojolProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      details: details ?? this.details,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory TransactionEntity.fromModel(TransactionModel model) {
    return TransactionEntity(
      id: model.id,
      idServer: model.idServer,
      shiftId: model.shiftId,
      outletId: model.outletId!,
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
      isPaid: model.isPaid ?? false,
      status: model.status ?? TransactionStatus.pending,
      cancelationOtp: model.cancelationOtp,
      cancelationReason: model.cancelationReason,
      ojolProvider: model.ojolProvider,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
      syncedAt: model.syncedAt,
      details: model.details
          ?.map((m) => TransactionDetailEntity.fromModel(m))
          .toList(),
    );
  }

  TransactionModel toModel() {
    return TransactionModel(
      id: id,
      idServer: idServer,
      shiftId: shiftId,
      outletId: outletId,
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
      status: status,
      isPaid: isPaid,
      cancelationOtp: cancelationOtp,
      cancelationReason: cancelationReason,
      ojolProvider: ojolProvider,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      syncedAt: syncedAt,
      details: details?.map((d) => d.toModel()).toList(),
    );
  }

  // status conversion helpers moved to the data model where DB/JSON
  // serialization occurs. Keep this entity focused on domain logic.

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity &&
        other.id == id &&
        other.shiftId == shiftId &&
        other.outletId == outletId &&
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
        other.ojolProvider == ojolProvider &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        idServer,
        shiftId,
        outletId,
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
        ojolProvider,
        createdAt,
        updatedAt,
        deletedAt,
        syncedAt,
      ]);

  @override
  String toString() {
    return 'TransactionEntity(id: $id, idServer: $idServer, shiftId: $shiftId, outletId: $outletId, sequenceNumber: $sequenceNumber, orderTypeId: $orderTypeId, categoryOrder: $categoryOrder, userId: $userId, paymentMethod: $paymentMethod, date: $date, notes: $notes, totalAmount: $totalAmount, totalQty: $totalQty, paidAmount: $paidAmount, changeMoney: $changeMoney, status: $status, cancelationOtp: $cancelationOtp, cancelationReason: $cancelationReason, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, syncedAt: $syncedAt, details: $details)';
  }

  Color get statusColor => status.color;
  String get statusValue => status.value.toUpperCase();
}
