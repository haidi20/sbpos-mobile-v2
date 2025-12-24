import 'package:core/core.dart';
// platform detection is used dynamically via `PlatformDetect`; no direct import required here
import 'package:product/data/datasources/product_remote.datasource.dart';
import 'package:sbpos_v2/main.dart';
// Menyediakan wiring default sederhana untuk fitur `product` agar contoh dan
// layar berfungsi tanpa perlu composition root aplikasi mengoverride provider.
// Ini dapat digantikan dengan komposisi yang lebih baik di produksi.
import 'package:product/data/datasources/packet_local.datasource.dart';
import 'package:product/data/repositories/packet.repository.impl.dart';
import 'package:product/presentation/providers/product_repository.provider.dart'
    show packetLocalDataSourceProvider, packetRepositoryProvider;
import 'package:product/data/datasources/product_local.datasource.dart';
import 'package:product/data/repositories/product.repository.impl.dart';
import 'package:product/presentation/providers/product_repository.provider.dart'
    show productLocalDataSourceProvider, productRepositoryProvider;
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
    // Create concrete instances and override feature providers so screens
    // that expect `packetRepositoryProvider` will receive a real
    // `PacketRepositoryImpl` (backed by `PacketLocalDataSource`).
    final packetLocal = PacketLocalDataSource();
    final packetRepo = PacketRepositoryImpl(local: packetLocal);
    final productLocal = ProductLocalDataSource();
    final productRepo = ProductRepositoryImpl(
      local: productLocal,
      remote: ProductRemoteDataSource(),
    );

    runApp(ProviderScope(overrides: [
      packetLocalDataSourceProvider.overrideWithValue(packetLocal),
      packetRepositoryProvider.overrideWithValue(packetRepo),
      productLocalDataSourceProvider.overrideWithValue(productLocal),
      productRepositoryProvider.overrideWithValue(productRepo),
    ], child: const MyApp()));
  } catch (e, stack) {
    Logger('MainLocal').severe('Error during initialization', e, stack);
  }
}
