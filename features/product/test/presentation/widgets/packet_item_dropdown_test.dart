// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/product.entity.dart';

void main() {
  group('Packet item dropdown logic', () {
    testWidgets('deduplicates products by id and shows base option',
        (tester) async {
      final notifier = ValueNotifier<List<ProductEntity>>([
        const ProductEntity(id: 1, name: 'A'),
        const ProductEntity(id: 1, name: 'A (dup)'),
        const ProductEntity(id: 2, name: 'B'),
      ]);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ValueListenableBuilder<List<ProductEntity>>(
              valueListenable: notifier,
              builder: (ctx, list, _) {
                final options = <DropdownMenuItem<int?>>[
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('- Pilih produk -')),
                ];
                final seen = <int>{};
                for (final p in list) {
                  final pid = p.id;
                  if (pid == null) continue;
                  if (seen.contains(pid)) continue;
                  seen.add(pid);
                  options.add(DropdownMenuItem<int?>(
                      value: pid, child: Text(p.name ?? '-')));
                }

                return DropdownButton<int?>(
                  value: null,
                  items: options,
                  onChanged: (_) {},
                );
              },
            );
          }),
        ),
      ));

      // Base option visible as selected child
      expect(find.text('- Pilih produk -'), findsOneWidget);

      // Open dropdown to reveal menu items
      await tester.tap(find.byType(DropdownButton<int?>).first);
      await tester.pumpAndSettle();

      // Menu should contain unique product names A and B, not the duplicate
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('A (dup)'), findsNothing);
    });

    testWidgets('includes currently selected product even if missing',
        (tester) async {
      final notifier = ValueNotifier<List<ProductEntity>>([
        const ProductEntity(id: 2, name: 'B'),
      ]);

      // selected id 1 is not inside the notifier list
      const selectedId = 1;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ValueListenableBuilder<List<ProductEntity>>(
              valueListenable: notifier,
              builder: (ctx, list, _) {
                final options = <DropdownMenuItem<int?>>[
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('- Pilih produk -')),
                ];
                final seen = <int>{};
                for (final p in list) {
                  final pid = p.id;
                  if (pid == null) continue;
                  if (seen.contains(pid)) continue;
                  seen.add(pid);
                  options.add(DropdownMenuItem<int?>(
                      value: pid, child: Text(p.name ?? '-')));
                }

                if (!options.any((e) => e.value == selectedId)) {
                  options.add(DropdownMenuItem<int?>(
                      value: selectedId, child: const Text('Unknown product')));
                }

                return DropdownButton<int?>(
                  value: selectedId,
                  items: options,
                  onChanged: (_) {},
                );
              },
            );
          }),
        ),
      ));

      // Selected child shows 'Unknown product'
      expect(find.text('Unknown product'), findsOneWidget);

      // Open dropdown to reveal menu items and check for 'B'
      await tester.tap(find.byType(DropdownButton<int?>).first);
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
    });
  });
}
