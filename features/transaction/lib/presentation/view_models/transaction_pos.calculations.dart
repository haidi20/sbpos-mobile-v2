import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

int calculateCartTotal(List<TransactionDetailEntity> details) {
  return details.fold<int>(0, (sum, item) {
    if (item.subtotal != null) return sum + (item.subtotal ?? 0);
    final price = item.productPrice ?? 0;
    final qty = item.qty ?? 0;
    return sum + (price * qty);
  });
}

int calculateCartCount(List<TransactionDetailEntity> details) =>
    details.fold(0, (sum, item) => sum + (item.qty ?? 0));

int calculateCartTotalValue(List<TransactionDetailEntity> details) {
  return details.fold<int>(0, (s, d) {
    final price = d.productPrice ?? 0;
    final qty = d.qty ?? 1;
    final subtotal = d.subtotal ?? (price * qty);
    return s + subtotal;
  });
}

int calculateTaxValue(List<TransactionDetailEntity> details,
    {double rate = 0.1}) {
  final cartTotal = calculateCartTotalValue(details);
  return (cartTotal * rate).round();
}

int calculateGrandTotalValue(List<TransactionDetailEntity> details) {
  final cart = calculateCartTotalValue(details);
  final tax = calculateTaxValue(details);
  return cart + tax;
}

int calculateChangeValue(
    int cashReceived, List<TransactionDetailEntity> details) {
  final grand = calculateGrandTotalValue(details);
  return cashReceived - grand;
}
