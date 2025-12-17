import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';

abstract class PacketRepository {
  Future<Either<Failure, List<PacketEntity>>> getPackets(
      {String? query, bool? isOffline});
  Future<Either<Failure, PacketEntity>> getPacket(int id, {bool? isOffline});
  Future<Either<Failure, PacketEntity>> createPacket(PacketEntity packet,
      {bool? isOffline});
  Future<Either<Failure, PacketEntity>> updatePacket(PacketEntity packet,
      {bool? isOffline});
  Future<Either<Failure, bool>> deletePacket(int id, {bool? isOffline});
}
