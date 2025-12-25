import 'package:core/core.dart';
import 'package:sbpos_v2/main.dart';
// Menyediakan wiring default sederhana untuk fitur `product` agar contoh dan
// layar berfungsi tanpa perlu composition root aplikasi mengoverride provider.
// Ini dapat digantikan dengan komposisi yang lebih baik di produksi.
import 'package:flutter/foundation.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env.local");
    await initializeDateFormatting('id_ID', null);

    // Setup logging sekali di awal app
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      final logMsg = '[${record.loggerName}] '
          '${record.level.name.padRight(7)} | '
          '${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')} | '
          '${record.message}';
      if (kDebugMode) {
        debugPrint(logMsg);
        // optional: print stack trace in debug
        if (record.error != null) debugPrint(record.error.toString());
        if (record.stackTrace != null) debugPrint(record.stackTrace.toString());
        // Print to browser console if running on web
        try {
          // PlatformDetect from core package
          // if (PlatformDetect.isWeb) {
          //   print('[WEB] $logMsg');
          //   if (record.error != null) print('[WEB] ERROR: ${record.error}');
          //   if (record.stackTrace != null) {
          //     print('[WEB] STACK: ${record.stackTrace}');
          //   }
          // }
        } catch (_) {}
      }
    });

    Logger('MainLocal').info('.env.local loaded successfully');
    // Use production providers (no local overrides) so transaction uses
    // production data sources for products and packets.
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stack) {
    Logger('MainLocal').severe('Error during initialization', e, stack);
  }
}
