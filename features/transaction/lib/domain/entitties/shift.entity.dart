import 'package:transaction/data/models/shift.model.dart';

class ShiftEntity {
  final int? id;
  final int? idServer;
  final int? shiftNumber;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? openingBalance;
  final int? closingBalance;
  final int? totalTransaction;
  final int? outletId;
  final int? userId;
  final bool? isClosed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  const ShiftEntity({
    this.id,
    this.idServer,
    this.shiftNumber,
    this.date,
    this.startTime,
    this.endTime,
    this.openingBalance,
    this.closingBalance,
    this.totalTransaction,
    this.outletId,
    this.userId,
    this.isClosed,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });

  ShiftEntity copyWith({
    int? id,
    int? idServer,
    int? shiftNumber,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? openingBalance,
    int? closingBalance,
    int? totalTransaction,
    int? outletId,
    int? userId,
    bool? isClosed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? syncedAt,
  }) {
    return ShiftEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      shiftNumber: shiftNumber ?? this.shiftNumber,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      openingBalance: openingBalance ?? this.openingBalance,
      closingBalance: closingBalance ?? this.closingBalance,
      totalTransaction: totalTransaction ?? this.totalTransaction,
      outletId: outletId ?? this.outletId,
      userId: userId ?? this.userId,
      isClosed: isClosed ?? this.isClosed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory ShiftEntity.fromModel(ShiftModel model) {
    return ShiftEntity(
      id: model.id,
      idServer: model.idServer,
      shiftNumber: model.shiftNumber,
      date: model.date,
      startTime: model.startTime,
      endTime: model.endTime,
      openingBalance: model.openingBalance,
      closingBalance: model.closingBalance,
      totalTransaction: model.totalTransaction,
      outletId: model.outletId,
      userId: model.userId,
      isClosed: model.isClosed,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
      syncedAt: model.syncedAt,
    );
  }

  ShiftModel toModel() {
    return ShiftModel(
      id: id,
      idServer: idServer,
      shiftNumber: shiftNumber,
      date: date,
      startTime: startTime,
      endTime: endTime,
      openingBalance: openingBalance,
      closingBalance: closingBalance,
      totalTransaction: totalTransaction,
      outletId: outletId,
      userId: userId,
      isClosed: isClosed,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      syncedAt: syncedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShiftEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.shiftNumber == shiftNumber &&
        other.date == date &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.openingBalance == openingBalance &&
        other.closingBalance == closingBalance &&
        other.totalTransaction == totalTransaction &&
        other.outletId == outletId &&
        other.userId == userId &&
        other.isClosed == isClosed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.syncedAt == syncedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        idServer,
        shiftNumber,
        date,
        startTime,
        endTime,
        openingBalance,
        closingBalance,
        totalTransaction,
        outletId,
        userId,
        isClosed,
        createdAt,
        updatedAt,
        deletedAt,
        syncedAt,
      );

  @override
  String toString() {
    return 'ShiftEntity(id: $id, idServer: $idServer, shiftNumber: $shiftNumber, date: $date, startTime: $startTime, endTime: $endTime, openingBalance: $openingBalance, closingBalance: $closingBalance, totalTransaction: $totalTransaction, outletId: $outletId, userId: $userId, isClosed: $isClosed, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, syncedAt: $syncedAt)';
  }
}
