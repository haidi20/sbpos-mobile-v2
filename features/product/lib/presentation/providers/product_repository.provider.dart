import 'package:core/core.dart';
import 'package:product/domain/repositories/product.repository.dart';
import 'package:product/domain/repositories/packet.repository.dart';

/// Lightweight repository tokens for the feature layer.
///
/// Concrete implementations are wired at the app composition root so importing
/// usecase/provider files does not automatically pull in remote/local
/// datasources and repository implementations during test/analyze startup.
final productRepositoryProvider = Provider<ProductRepository?>(
  (ref) => throw UnimplementedError(
    'productRepositoryProvider must be overridden in the app composition root.',
  ),
);

final packetRepositoryProvider = Provider<PacketRepository>(
  (ref) => throw UnimplementedError(
    'packetRepositoryProvider must be overridden in the app composition root.',
  ),
);
