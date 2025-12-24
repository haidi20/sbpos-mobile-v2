// Ini adalah tes widget Flutter dasar.
//
// Untuk berinteraksi dengan widget di tes Anda, gunakan `WidgetTester`
// dari paket `flutter_test`. Misalnya, Anda dapat mengirim tap dan scroll
// gestures. Anda juga dapat menggunakan `WidgetTester` untuk menemukan child widget
// dalam tree, membaca teks, dan memverifikasi bahwa nilai properti widget benar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:customer/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
