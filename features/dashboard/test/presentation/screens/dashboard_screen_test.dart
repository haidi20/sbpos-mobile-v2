import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen builds without error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
