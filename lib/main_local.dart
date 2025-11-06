import 'package:core/core.dart';
import 'package:sbpos_v2/main.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env.local");
    await initializeDateFormatting('id_ID', null);

    // Setup logging sekali di awal app
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('[${record.loggerName}] '
          '${record.level.name.padRight(7)} | '
          '${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')} | '
          '${record.message}');
      // opsional: cetak stack trace jika ada
      if (record.error != null) print(record.error);
      if (record.stackTrace != null) print(record.stackTrace);
    });

    Logger('MainLocal').info('.env.local loaded successfully');
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stack) {
    Logger('MainLocal').severe('Error during initialization', e, stack);
  }
}
