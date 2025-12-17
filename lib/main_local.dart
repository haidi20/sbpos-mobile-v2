import 'package:core/core.dart';
import 'package:product/data/datasources/product_remote.datasource.dart';
import 'package:sbpos_v2/main.dart';
// Provide a simple default wiring for the `product` feature so examples
// and screens work without requiring the app composition root to override
// providers. This can be replaced by a better composition in production.
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
