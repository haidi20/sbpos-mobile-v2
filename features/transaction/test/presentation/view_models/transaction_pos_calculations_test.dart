import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/presentation/view_models/transaction_pos.calculations.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

void main() {
  group('transaction_pos.calculations', () {
    test('calculateCartTotal sums subtotal when present', () {
      final details = [
        TransactionDetailEntity(subtotal: 5000),
        TransactionDetailEntity(subtotal: 3000),
      ];
      final total = calculateCartTotal(details);
      expect(total, 8000);
    });

    test('calculateCartTotal computes price * qty when subtotal null', () {
      final details = [
        TransactionDetailEntity(productPrice: 2000, qty: 2),
        TransactionDetailEntity(productPrice: 1500, qty: 1),
      ];
      final total = calculateCartTotal(details);
      expect(total, 2000 * 2 + 1500);
    });

    test('calculateCartCount sums quantities', () {
      final details = [
        TransactionDetailEntity(qty: 2),
        TransactionDetailEntity(qty: 3),
      ];
      expect(calculateCartCount(details), 5);
    });

    test('calculateCartTotalValue uses subtotal or price*qty', () {
      final details = [
        TransactionDetailEntity(productPrice: 1000, qty: 2),
        TransactionDetailEntity(subtotal: 5000, productPrice: 1000, qty: 5),
      ];
      expect(calculateCartTotalValue(details), 2000 + 5000);
    });

    test('calculateTaxValue uses 10% by default', () {
      final details = [
        TransactionDetailEntity(productPrice: 1000, qty: 10), // 10000
      ];
      expect(calculateTaxValue(details), 1000);
    });

    test('calculateGrandTotalValue sums cart + tax', () {
      final details = [
        TransactionDetailEntity(productPrice: 1000, qty: 2), // 2000
      ];
      expect(calculateGrandTotalValue(details), 2000 + 200);
    });

    test('calculateChangeValue returns cash - grandTotal', () {
      final details = [
        TransactionDetailEntity(productPrice: 1000, qty: 2), // 2000
      ];
      expect(calculateChangeValue(3000, details), 3000 - 2200);
    });
  });
}
