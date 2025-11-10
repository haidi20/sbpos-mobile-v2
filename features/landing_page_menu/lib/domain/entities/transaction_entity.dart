import 'package:core/domain/entities/user_entity.dart';
import 'package:landing_page_menu/data/models/transaction_model.dart';
import 'package:landing_page_menu/domain/entities/order_type_entity.dart';
import 'package:warehouse/domain/entities/warehouse_entity.dart';

class TransactionEntity {
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

  // Relasi sebagai Entity
  final WarehouseEntity? warehouse;
  final UserEntity? user;
  final OrderTypeEntity? orderType;

  const TransactionEntity({
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
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    WarehouseEntity? warehouse,
    UserEntity? user,
    OrderTypeEntity? orderType,
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
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      warehouse: warehouse ?? this.warehouse,
      user: user ?? this.user,
      orderType: orderType ?? this.orderType,
    );
  }

  factory TransactionEntity.fromModel(TransactionModel model) {
    return TransactionEntity(
      id: model.id,
      shiftId: model.shiftId,
      warehouseId: model.warehouseId,
      sequenceNumber: model.sequenceNumber,
      orderTypeId: model.orderTypeId,
      categoryOrder: model.categoryOrder,
      userId: model.userId,
      paymentMethod: model.paymentMethod,
      date: model.date,
      notes: model.notes,
      totalAmount: model.totalAmount,
      totalQty: model.totalQty,
      paidAmount: model.paidAmount,
      changeMoney: model.changeMoney,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      warehouse: model.warehouse?.toEntity(),
      user: model.user?.toEntity(),
      orderType: model.orderType?.toEntity(),
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
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      warehouse: warehouse?.toModel(),
      user: user?.toModel(),
      orderType: orderType?.toModel(),
    );
  }

  List<Object?> get props => [
        id,
        shiftId,
        warehouseId,
        sequenceNumber,
        orderTypeId,
        categoryOrder,
        userId,
        paymentMethod,
        date.millisecondsSinceEpoch,
        notes,
        totalAmount,
        totalQty,
        paidAmount,
        changeMoney,
        deletedAt?.millisecondsSinceEpoch,
        createdAt?.millisecondsSinceEpoch,
        updatedAt?.millisecondsSinceEpoch,
        warehouse,
        user,
        orderType,
      ];

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
        other.date.millisecondsSinceEpoch == date.millisecondsSinceEpoch &&
        other.notes == notes &&
        other.totalAmount == totalAmount &&
        other.totalQty == totalQty &&
        other.paidAmount == paidAmount &&
        other.changeMoney == changeMoney &&
        other.deletedAt?.millisecondsSinceEpoch ==
            deletedAt?.millisecondsSinceEpoch &&
        other.createdAt?.millisecondsSinceEpoch ==
            createdAt?.millisecondsSinceEpoch &&
        other.updatedAt?.millisecondsSinceEpoch ==
            updatedAt?.millisecondsSinceEpoch &&
        other.warehouse == warehouse &&
        other.user == user &&
        other.orderType == orderType;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      shiftId,
      warehouseId,
      sequenceNumber,
      orderTypeId,
      categoryOrder,
      userId,
      paymentMethod,
      date.millisecondsSinceEpoch,
      notes,
      totalAmount,
      totalQty,
      paidAmount,
      changeMoney,
      deletedAt?.millisecondsSinceEpoch,
      createdAt?.millisecondsSinceEpoch,
      updatedAt?.millisecondsSinceEpoch,
      warehouse,
      user,
      orderType,
    ]);
  }
}
