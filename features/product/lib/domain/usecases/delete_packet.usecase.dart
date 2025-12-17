import 'package:core/core.dart';
import 'package:product/domain/repositories/packet.repository.dart';

class DeletePacket {
  final PacketRepository repository;
  DeletePacket(this.repository);

  Future<Either<Failure, bool>> call(int id, {bool? isOffline}) async {
    return await repository.deletePacket(id, isOffline: isOffline);
  }
}
