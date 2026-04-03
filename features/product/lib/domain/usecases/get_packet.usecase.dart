import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/repositories/packet.repository.dart';

class GetPacket {
  final PacketRepository repository;

  GetPacket(this.repository);

  Future<Either<Failure, PacketEntity>> call(int id, {bool? isOffline}) async {
    try {
      return await repository.getPacket(id, isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
