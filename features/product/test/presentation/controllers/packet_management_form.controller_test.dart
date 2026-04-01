import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product/presentation/controllers/packet_management_form.controller.dart';

class MockWidgetRef extends Mock implements WidgetRef {}

void main() {
  testWidgets('openEditSheet harus membuka bottom sheet', (tester) async {
    final mockRef = MockWidgetRef();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final controller = PacketManagementFormController(mockRef);
                return ElevatedButton(
                  onPressed: () => controller.openEditSheet(context: context),
                  child: const Text('open-sheet'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Item'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Item'), findsNothing);
  });
}
