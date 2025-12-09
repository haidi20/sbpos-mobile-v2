// Host-side directory handling not needed; remove unused import
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// App entry and router
import 'package:sbpos_v2/main.dart' as app;
import 'package:core/core.dart';
// AppRoutes available via core.dart exports

// Specific screen requested will be reached via AppRoutes.settings

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Reduce noise from known layout overflows during automated screenshots
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('A RenderFlex overflowed')) {
      // Ignore overflow errors to keep screenshot run going
      return;
    }
    FlutterError.presentError(details);
  };

  group('Android screenshots - all routes + SettingScreen', () {
    testWidgets('Capture screenshots for all named routes', (tester) async {
      // Boot the real app
      app.main();

      // Allow app to settle
      // Try to settle briefly; if it times out, continue
      try {
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } catch (_) {
        await tester.pump(const Duration(milliseconds: 300));
      }

      final router = AppRouter.instance.router;
      // Use path-based routes from AppRoutes constants
      final routePaths = <String>[
        AppRoutes.login,
        AppRoutes.report,
        AppRoutes.settings,
        AppRoutes.dashboard,
        AppRoutes.warehouse,
        AppRoutes.inventory,
        AppRoutes.transaction,
        AppRoutes.landingPageMenu,
        AppRoutes.notification,
        AppRoutes.comingSoonScreen,
        AppRoutes.transactionPos,
        AppRoutes.productManagement,
        AppRoutes.transactionHistory,
      ];

      // Ensure output directory exists (host side)
      final outDir = Directory('screenshots/android/phone');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }

      for (final path in routePaths) {
        try {
          router.go(path);
          try {
            await tester.pumpAndSettle(const Duration(seconds: 1));
          } catch (_) {
            await tester.pump(const Duration(milliseconds: 300));
          }

          // Full device frame is controlled by emulator/device; we capture screen content.
          // Replace leading slash for file-friendly name
          final safeName = path.replaceAll('/', '');
          await binding.takeScreenshot('android/phone/$safeName');
        } catch (e) {
          // Continue on navigation errors to avoid failing whole batch
          // You may review logs to fix specific routes later.
          // ignore: avoid_print
          print('Skip route "$path": $e');
        }
      }
    });

    // SettingScreen covered via AppRoutes.settings
  });
}

// Removed dynamic route name collection; using AppRoutes constants for stability
