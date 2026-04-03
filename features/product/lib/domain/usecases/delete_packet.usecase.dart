import 'package:core/core.dart';
import 'package:product/domain/repositories/packet.repository.dart';

class DeletePacket {
  final PacketRepository repository;
  DeletePacket(this.repository);

  Future<Either<Failure, bool>> call(int id, {bool? isOffline}) async {
    try {
      return await repository.deletePacket(id, isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
