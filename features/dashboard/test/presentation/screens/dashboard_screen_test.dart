import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen builds without throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    // Ensure the screen exists in the widget tree
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
