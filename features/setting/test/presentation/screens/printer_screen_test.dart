import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/printer_screen.dart';

import 'package:setting/testing/test_helpers.dart';

void main() {
  testWidgets('PrinterScreen menampilkan judul dan tombol test print',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    expect(find.text('Printer & Struk'), findsWidgets);
    expect(find.text('Test Print'), findsOneWidget);
  });

  testWidgets('PrinterScreen menampilkan banner pencarian printer',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    expect(find.text('Mencari Printer...'), findsOneWidget);
    expect(find.text('Pastikan bluetooth printer aktif'), findsOneWidget);
  });

  testWidgets('PrinterScreen menampilkan device default yang terhubung',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    expect(find.text('Epson TM-T82'), findsOneWidget);
    expect(find.text('Terhubung'), findsOneWidget);
    expect(find.text('Putus'), findsOneWidget);
  });

  testWidgets('tap Putus mengubah status printer menjadi terputus',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    await tester.tap(find.text('Putus'));
    await tester.pumpAndSettle();

    final printerState = container.read(settingViewModelProvider).printer;
    expect(printerState.devices.first.isConnected, isFalse);
    expect(printerState.devices.first.subtitle, equals('Terputus'));
    expect(printerState.message, equals('Epson TM-T82 berhasil diputus'));
    expect(find.text('Terputus'), findsOneWidget);
  });

  testWidgets('setelah printer diputus tombol aksi menjadi nonaktif',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    await tester.tap(find.text('Putus'));
    await tester.pumpAndSettle();

    final buttons = tester
        .widgetList<TextButton>(find.widgetWithText(TextButton, 'Nonaktif'))
        .toList();
    expect(buttons, isNotEmpty);
    expect(buttons.every((button) => button.onPressed == null), isTrue);
  });

  testWidgets('toggle Auto Print Struk mengubah state provider',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    await tester.tap(find.text('Auto Print Struk'));
    await tester.pumpAndSettle();

    expect(container.read(settingViewModelProvider).printer.autoPrint, isFalse);
  });

  testWidgets('toggle Cetak Logo Toko mengubah state provider',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    await tester.tap(find.text('Cetak Logo Toko'));
    await tester.pumpAndSettle();

    expect(container.read(settingViewModelProvider).printer.printLogo, isFalse);
  });

  testWidgets('ubah lebar kertas mengubah pilihan provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('58mm').last);
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).printer.paperWidth,
      equals('58mm'),
    );
  });

  testWidgets('test print saat printer terhubung memunculkan pesan sukses',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
    );

    await tester.ensureVisible(find.byKey(const Key('printer-test-print-button')));
    await tester.tap(find.byKey(const Key('printer-test-print-button')));
    await tester.pumpAndSettle();

    final printerState = container.read(settingViewModelProvider).printer;
    expect(printerState.isError, isFalse);
    expect(
      printerState.message,
      equals('Test print berhasil'),
    );
    expect(find.text('Test print berhasil'), findsOneWidget);
  });

  testWidgets('test print saat printer terputus memunculkan pesan error',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
      arrange: (container) {
        container
            .read(settingViewModelProvider.notifier)
            .setPrinterConnected('Epson TM-T82', false);
      },
    );

    await tester.ensureVisible(find.byKey(const Key('printer-test-print-button')));
    await tester.tap(find.byKey(const Key('printer-test-print-button')));
    await tester.pumpAndSettle();

    final printerState = container.read(settingViewModelProvider).printer;
    expect(printerState.isError, isTrue);
    expect(
      printerState.message,
      equals('Tidak ada printer yang terhubung untuk test print'),
    );
    expect(
      find.text('Tidak ada printer yang terhubung untuk test print'),
      findsOneWidget,
    );
  });

  testWidgets('tap tombol back kembali ke root route', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.printer,
      screen: const PrinterScreen(),
      pushFromRoot: true,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text(kSettingTestRootText), findsOneWidget);
  });
}
