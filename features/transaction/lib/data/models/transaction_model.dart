import 'package:transaction/data/models/transaction_item_model.dart';

class TransactionModel {
  final int? id;
  final int? shiftId;
  final int? warehouseId;
  final int? sequenceNumber;
  final int? orderTypeId;
  final String? categoryOrder;
  final int? userId;
  final String? paymentMethod;
  final String? date;
  final String? notes;
  final double? totalAmount;
  final int? totalQty;
  final double? paidAmount;
  final double? changeMoney;
  final String? status;
  final List<TransactionItemModel>? items;

  TransactionModel({
    this.id,
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
    this.items,
  });
}
