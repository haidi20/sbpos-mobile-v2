import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/repositories/packet.repository.dart';

class UpdatePacket {
  final PacketRepository repository;
  UpdatePacket(this.repository);

  Future<Either<Failure, PacketEntity>> call(PacketEntity packet,
      {bool? isOffline}) async {
    return await repository.updatePacket(packet, isOffline: isOffline);
  }
}
