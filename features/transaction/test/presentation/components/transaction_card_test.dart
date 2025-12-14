import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/presentation/components/transaction.card.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/data/dummy/transaction.dummy.dart';

void main() {
  group('TransactionCard widget', () {
    testWidgets('renders with TransactionEntity without throwing',
        (WidgetTester tester) async {
      final model = transactionList.first; // dummy TransactionModel
      final entity = TransactionEntity.fromModel(model);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TransactionCard(tx: entity, onTap: () {}),
        ),
      ));

      // Basic assertions: contains order label and amount
      expect(find.textContaining('Order #'), findsOneWidget);
      expect(find.textContaining('Rp'), findsOneWidget);
    });

    testWidgets('renders with TransactionModel without throwing',
        (WidgetTester tester) async {
      final model = transactionList.first; // dummy TransactionModel

      final entity = TransactionEntity.fromModel(model);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TransactionCard(tx: entity, onTap: () {}),
        ),
      ));

      // Basic assertions: contains order label and amount
      expect(find.textContaining('Order #'), findsOneWidget);
      expect(find.textContaining('Rp'), findsOneWidget);
    });
  });
}
