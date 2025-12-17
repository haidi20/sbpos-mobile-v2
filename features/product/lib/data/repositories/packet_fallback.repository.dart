import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/repositories/packet.repository.dart';

/// A lightweight fallback PacketRepository used when no concrete repository
/// is wired in the application composition root. It returns empty/safe
/// default values to avoid null-check crashes in the UI.
class PacketRepositoryFallback implements PacketRepository {
  static final _emptyPacket =
      PacketEntity(id: 0, name: '', price: 0, items: []);

  @override
  Future<Either<Failure, List<PacketEntity>>> getPackets(
      {String? query, bool? isOffline}) async {
    return right(<PacketEntity>[]);
  }

  @override
  Future<Either<Failure, PacketEntity>> getPacket(int id,
      {bool? isOffline}) async {
    return right(_emptyPacket.copyWith(id: id));
  }

  @override
  Future<Either<Failure, PacketEntity>> createPacket(PacketEntity packet,
      {bool? isOffline}) async {
    return right(packet.copyWith(id: packet.id ?? 0));
  }

  @override
  Future<Either<Failure, PacketEntity>> updatePacket(PacketEntity packet,
      {bool? isOffline}) async {
    return right(packet);
  }

  @override
  Future<Either<Failure, bool>> deletePacket(int id, {bool? isOffline}) async {
    return right(true);
  }
}
