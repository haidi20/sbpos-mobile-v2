class ShiftModel {
  final int? id;
  final int? idServer;
  final int? shiftNumber;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? openingBalance;
  final int? closingBalance;
  final int? totalTransaction;
  final int? warehouseId;
  final int? userId;
  final bool? isClosed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  ShiftModel({
    this.id,
    this.idServer,
    this.shiftNumber,
    this.date,
    this.startTime,
    this.endTime,
    this.openingBalance,
    this.closingBalance,
    this.totalTransaction,
    this.warehouseId,
    this.userId,
    this.isClosed,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });

  ShiftModel copyWith({
    int? id,
    int? idServer,
    int? shiftNumber,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? openingBalance,
    int? closingBalance,
    int? totalTransaction,
    int? warehouseId,
    int? userId,
    bool? isClosed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? syncedAt,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      shiftNumber: shiftNumber ?? this.shiftNumber,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      openingBalance: openingBalance ?? this.openingBalance,
      closingBalance: closingBalance ?? this.closingBalance,
      totalTransaction: totalTransaction ?? this.totalTransaction,
      warehouseId: warehouseId ?? this.warehouseId,
      userId: userId ?? this.userId,
      isClosed: isClosed ?? this.isClosed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory ShiftModel.fromJson(Map<String, dynamic> json) => ShiftModel(
        idServer: _toInt(json['id']),
        shiftNumber: _toInt(json['shift_number']),
        date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
        startTime: json['start_time'] != null
            ? DateTime.tryParse(json['start_time'])
            : null,
        endTime: json['end_time'] != null
            ? DateTime.tryParse(json['end_time'])
            : null,
        openingBalance: _toInt(json['opening_balance']),
        closingBalance: _toInt(json['closing_balance']),
        totalTransaction: _toInt(json['total_transaction']),
        warehouseId: _toInt(json['warehouse_id']),
        userId: _toInt(json['user_id']),
        isClosed: _toBool(json['is_closed']),
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
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_server': idServer,
        'shift_number': shiftNumber,
        'date': date?.toIso8601String(),
        'start_time': startTime?.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'opening_balance': openingBalance,
        'closing_balance': closingBalance,
        'total_transaction': totalTransaction,
        'warehouse_id': warehouseId,
        'user_id': userId,
        'is_closed': isClosed == null ? null : (isClosed! ? 1 : 0),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer,
        'shift_number': shiftNumber,
        'date': date?.toIso8601String(),
        'start_time': startTime?.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'opening_balance': openingBalance,
        'closing_balance': closingBalance,
        'total_transaction': totalTransaction,
        'warehouse_id': warehouseId,
        'user_id': userId,
        'is_closed': isClosed == null ? null : (isClosed! ? 1 : 0),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  factory ShiftModel.fromDbLocal(Map<String, dynamic> map) => ShiftModel(
        id: _toInt(map['id']),
        idServer: _toInt(map['id_server']),
        shiftNumber: _toInt(map['shift_number']),
        date: _toDate(map['date']),
        startTime: _toDate(map['start_time']),
        endTime: _toDate(map['end_time']),
        openingBalance: _toInt(map['opening_balance']) ?? 0,
        closingBalance: _toInt(map['closing_balance']) ?? 0,
        totalTransaction: _toInt(map['total_transaction']) ?? 0,
        warehouseId: _toInt(map['warehouse_id']),
        userId: _toInt(map['user_id']),
        isClosed: _toBool(map['is_closed']),
        createdAt: _toDate(map['created_at']),
        updatedAt: _toDate(map['updated_at']),
        deletedAt: _toDate(map['deleted_at']),
        syncedAt: _toDate(map['synced_at']),
      );

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

  static bool? _toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) {
      final i = int.tryParse(v);
      if (i != null) return i != 0;
      if (v.toLowerCase() == 'true') return true;
      if (v.toLowerCase() == 'false') return false;
    }
    return null;
  }
}
