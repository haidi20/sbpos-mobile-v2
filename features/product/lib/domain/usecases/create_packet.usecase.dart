import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/repositories/packet.repository.dart';

class CreatePacket {
  final PacketRepository repository;
  CreatePacket(this.repository);

  Future<Either<Failure, PacketEntity>> call(PacketEntity packet,
      {bool? isOffline}) async {
    try {
      return await repository.createPacket(packet, isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
