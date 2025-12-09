import 'package:core/core.dart';
import 'package:sbpos_v2/main.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env.local");
    await initializeDateFormatting('id_ID', null);

    // Setup logging sekali di awal app
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        debugPrint('[${record.loggerName}] '
            '${record.level.name.padRight(7)} | '
            '${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')} | '
            '${record.message}');
        // optional: print stack trace in debug
        if (record.error != null) debugPrint(record.error.toString());
        if (record.stackTrace != null) debugPrint(record.stackTrace.toString());
      }
    });

    Logger('MainLocal').info('.env.local loaded successfully');
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stack) {
    Logger('MainLocal').severe('Error during initialization', e, stack);
  }
}
