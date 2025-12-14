// ignore_for_file: avoid_print

import 'dart:ui' as ui show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// App entry and router
import 'package:sbpos_v2/main.dart' as app;
import 'package:core/core.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Durasi default untuk menunggu (pumping) dan menyelesaikan animasi (settle)
  const Duration defaultPump = Duration(milliseconds: 500);
  const Duration settleTimeout = Duration(seconds: 10);

  // 1) Abaikan sebagian error layout yang umum saat test (tidak fatal)
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('A RenderFlex overflowed') ||
        message.contains('BoxConstraints forces an infinite width') ||
        message.contains('RenderBox was not laid out')) {
      return;
    }
    FlutterError.presentError(details);
  };

  Future<void> settleSoft(WidgetTester tester,
      {Duration timeout = settleTimeout}) async {
    try {
      await tester.pumpAndSettle(timeout);
    } catch (_) {
      await tester.pump(defaultPump);
    }
  }

  Future<void> tapIfExists(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder.first);
      await settleSoft(tester);
    }
  }

  Future<void> safeTakeScreenshot(String name) async {
    try {
      await binding.takeScreenshot(name);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('convertFlutterSurfaceToImage')) {
        try {
          await binding.convertFlutterSurfaceToImage();
          // Ensure a stable surface size for consistent layout
          await binding.setSurfaceSize(const ui.Size(1080, 1920));
          await binding.takeScreenshot(name);
          return;
        } catch (e2) {
          print('Retry screenshot failed: $e2');
        }
      }
      rethrow;
    }
  }

  Future<void> navigateAndCapture(
    WidgetTester tester,
    String path,
  ) async {
    final router = AppRouter.instance.router;
    router.go(path);
    await settleSoft(tester);
    await tester.pump(defaultPump);

    final safeName = path.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    // Extra settle for known heavy screens
    final heavy = {
      AppRoutes.printer,
      AppRoutes.help,
    };
    if (heavy.contains(path)) {
      try {
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } catch (_) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }
    await safeTakeScreenshot('android_phone_$safeName');
    print('Screenshot sukses untuk rute: $path');
  }

  group('Android screenshots (integration_test) - AppRoutes', () {
    testWidgets('Capture screenshots for all route paths', (tester) async {
      // 2) Boot aplikasi
      app.main();

      // Settle awal untuk inisialisasi, splash, dan redirect
      await settleSoft(tester);

      // Wajib untuk Android Surface sebelum mengambil screenshot
      try {
        await binding.convertFlutterSurfaceToImage();
      } catch (e) {
        print('convertFlutterSurfaceToImage gagal atau sudah di-set: $e');
      }
      // Set fixed surface size to stabilize layouts during screenshots
      try {
        await binding.setSurfaceSize(const ui.Size(1080, 1920));
        await tester.pump(const Duration(milliseconds: 200));
      } catch (e) {
        print('setSurfaceSize failed: $e');
      }

      // 3) Simulasi login jika diperlukan
      await tapIfExists(tester, find.text('Masuk Aplikasi'));
      await tapIfExists(tester, find.byType(ElevatedButton));

      // 4) Daftar rute yang akan di-capture
      final routePaths = <String>[
        AppRoutes.dashboard,
        AppRoutes.transactionPos,
        AppRoutes.transactionHistory,
        AppRoutes.inventory,
        AppRoutes.productManagement,
        AppRoutes.report,
        AppRoutes.settings,
        AppRoutes.notification,
        // Rute Setting turunan
        AppRoutes.profile,
        AppRoutes.store,
        AppRoutes.security,
        AppRoutes.payment,
        AppRoutes.printer,
        AppRoutes.notificationSetting,
        AppRoutes.help,
        // Rute lainnya
        AppRoutes.comingSoonScreen,
        AppRoutes.login, // Ambil screenshot login di akhir
      ];

      // 5) Iterasi navigasi dan pengambilan screenshot
      for (final path in routePaths) {
        try {
          await navigateAndCapture(tester, path);
        } catch (e) {
          print('!!! Gagal mengambil screenshot rute "$path": $e');
        }
      }

      // 6) Screenshot akhir sebagai penanda selesai
      await safeTakeScreenshot('android_phone__final');
    });
  });
}
