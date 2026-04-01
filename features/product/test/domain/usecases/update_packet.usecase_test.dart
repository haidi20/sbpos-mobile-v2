import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/repositories/packet.repository.dart';
import 'package:product/domain/usecases/update_packet.usecase.dart';

class MockPacketRepository extends Mock implements PacketRepository {}

void main() {
  late MockPacketRepository mockRepository;
  late UpdatePacket usecase;

  setUp(() {
    mockRepository = MockPacketRepository();
    usecase = UpdatePacket(mockRepository);
    registerFallbackValue(PacketEntity());
  });

  final tPacket = PacketEntity(id: 1, name: 'Paket Diperbarui');

  test('harus memanggil repository untuk memperbarui paket', () async {
    // arrange
    when(() => mockRepository.updatePacket(any(), isOffline: any(named: 'isOffline')))
        .thenAnswer((_) async => Right(tPacket));

    // act
    final result = await usecase(tPacket);

    // assert
    expect(result, Right(tPacket));
    verify(() => mockRepository.updatePacket(tPacket, isOffline: null))
        .called(1);
  });
}
