import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/presentation/screens/main_dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen builds and shows header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('FAB opens quick actions modal and navigates to Order',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    // Tap FAB
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Modal should show
    expect(find.text('Quick Actions'), findsOneWidget);

    // Tap 'Order Baru' button
    final orderButton = find.widgetWithText(ElevatedButton, 'Order Baru');
    expect(orderButton, findsOneWidget);
    await tester.tap(orderButton);
    await tester.pumpAndSettle();

    // Now Order view header should be visible
    expect(find.text('Menu'), findsOneWidget);
  });

  testWidgets('Adding product to cart increases cart count', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    // Switch to Order tab using bottom nav
    final orderTab = find.widgetWithText(IconButton, 'Order');
    // The bottom nav uses IconButton with a Column child; tap by icon
    final orderIcon = find.byIcon(Icons.shopping_bag);
    expect(orderIcon, findsOneWidget);
    await tester.tap(orderIcon);
    await tester.pumpAndSettle();

    // Find first add icon in product grid and tap it
    final addButton = find.byIcon(Icons.add_circle).first;
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // After adding, badge with quantity should appear (we expect '1')
    expect(find.text('1'), findsWidgets);
  });
}
