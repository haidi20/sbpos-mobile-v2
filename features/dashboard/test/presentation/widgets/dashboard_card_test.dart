import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/presentation/widgets/dashboard_card.dart';

void main() {
  testWidgets('DashboardCard builds without error', (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: DashboardCard())));
    expect(find.byType(DashboardCard), findsOneWidget);
  });
}
