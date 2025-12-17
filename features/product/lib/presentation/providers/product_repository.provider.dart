import 'package:core/core.dart';
import 'package:product/data/datasources/product_local.datasource.dart';
import 'package:product/data/datasources/product_remote.datasource.dart';
import 'package:product/data/datasources/packet_local.datasource.dart';
import 'package:product/data/datasources/packet_remote.datasouece.dart';
import 'package:product/domain/repositories/product.repository.dart';
import 'package:product/domain/repositories/packet.repository.dart';
import 'package:product/data/repositories/product.repository.impl.dart';
import 'package:product/data/repositories/packet.repository.impl.dart';

/// Placeholder provider for remote datasource. Override in the app composition
/// root with a concrete implementation that implements `ProductRemoteDataSource`.
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>(
  (ref) => ProductRemoteDataSource(),
);

/// Placeholder provider for local datasource. Override in the app composition
/// root with a concrete implementation that constructs `ProductLocalDataSource`.
final productLocalDataSourceProvider = Provider<ProductLocalDataSource>(
  (ref) => ProductLocalDataSource(),
);

/// Repository provider for product feature. Override this in the app
/// composition root with a concrete `ProductRepository` (e.g. an instance of
/// `ProductRepositoryImpl`).
final productRepositoryProvider = Provider<ProductRepository?>(
  (ref) => ProductRepositoryImpl(
    remote: ref.read(productRemoteDataSourceProvider),
    local: ref.read(productLocalDataSourceProvider),
  ),
);

/// Packet placeholders - override in composition root
final packetRemoteDataSourceProvider =
    Provider<PacketRemoteDataSource>((ref) => PacketRemoteDataSource());

final packetLocalDataSourceProvider =
    Provider<PacketLocalDataSource>((ref) => PacketLocalDataSource());

final packetRepositoryProvider = Provider<PacketRepository>((ref) {
  return PacketRepositoryImpl(
    local: ref.read(packetLocalDataSourceProvider),
  );
});
