import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/presentation/screens/transaction_history.screen.dart';

void main() {
  testWidgets('TransactionHistoryScreen builds without exceptions',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: TransactionHistoryScreen()));

    // screen should contain title
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
  });
}
