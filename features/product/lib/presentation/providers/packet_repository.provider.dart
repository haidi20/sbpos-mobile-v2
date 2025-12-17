import 'package:core/core.dart';
import 'package:product/domain/repositories/packet.repository.dart';
import 'package:product/data/datasources/packet_local.datasource.dart';
import 'package:product/data/datasources/packet_remote.datasouece.dart';
import 'package:product/data/repositories/packet.repository.impl.dart';

/// Providers for packet repository and its datasources.
/// These provide simple concrete defaults but can be overridden in the
/// application composition root for testing or platform-specific wiring.

final packetRemoteDataSourceProvider = Provider<PacketRemoteDataSource>(
  (ref) => PacketRemoteDataSource(),
);

final packetLocalDataSourceProvider = Provider<PacketLocalDataSource>(
  (ref) => PacketLocalDataSource(),
);

final packetRepositoryProvider = Provider<PacketRepository?>(
  (ref) => PacketRepositoryImpl(
    local: ref.read(packetLocalDataSourceProvider),
  ),
);
