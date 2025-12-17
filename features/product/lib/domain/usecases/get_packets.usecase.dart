import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/repositories/packet.repository.dart';

class GetPackets {
  final PacketRepository repository;
  GetPackets(this.repository);

  Future<Either<Failure, List<PacketEntity>>> call(
      {String? query, bool? isOffline}) async {
    return await repository.getPackets(query: query, isOffline: isOffline);
  }
}
