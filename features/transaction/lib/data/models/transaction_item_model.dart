class TransactionItemModel {
  final int? id;
  final int? transactionId;
  final int? productId;
  final String? productName;
  final double? productPrice;
  final int? qty;
  final double? subtotal;

  TransactionItemModel({
    this.id,
    this.transactionId,
    this.productId,
    this.productName,
    this.productPrice,
    this.qty,
    this.subtotal,
  });
}
