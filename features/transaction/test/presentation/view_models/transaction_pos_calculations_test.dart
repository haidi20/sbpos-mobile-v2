import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/presentation/view_models/transaction_pos.calculations.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/category.entity.dart';

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

    test('calcIndexOfFirstProductForCategory returns correct index', () {
      final p1 = ProductEntity(
          id: 1, name: 'A', category: CategoryEntity(name: 'Food'));
      final p2 = ProductEntity(
          id: 2, name: 'B', category: CategoryEntity(name: 'Drink'));
      final p3 = ProductEntity(
          id: 3, name: 'C', category: CategoryEntity(name: 'Food'));
      final list = [p1, p2, p3];

      expect(calcIndexOfFirstProductForCategory(list, 'Drink'), 1);
      expect(calcIndexOfFirstProductForCategory(list, 'Food'), 0);
      expect(calcIndexOfFirstProductForCategory(list, 'Unknown'), -1);
    });

    test('calcComputeScrollTargetForIndex computes expected pixel offset', () {
      // Use a sample screen width and default layout params
      final screenW = 360.0;
      // index 0 -> row 0 -> offset 0
      final t0 = calcComputeScrollTargetForIndex(0, screenW);
      expect(t0, 0);

      // index 2 -> row 1 -> offset > 0
      final t2 = calcComputeScrollTargetForIndex(2, screenW);
      // compute expected manually
      final pItemWidth = (screenW - 32.0 - 12.0) / 2.0;
      final childHeight = pItemWidth / 0.75;
      final expectedRowHeight = childHeight + 12.0;
      expect(t2, closeTo(expectedRowHeight, 0.0001));
    });
  });
}
