import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/repositories/packet.repository.dart';
import 'package:product/domain/usecases/get_packet.usecase.dart';

class MockPacketRepository extends Mock implements PacketRepository {}

void main() {
  late MockPacketRepository mockRepository;
  late GetPacket usecase;

  setUp(() {
    mockRepository = MockPacketRepository();
    usecase = GetPacket(mockRepository);
  });

  final tPacket = PacketEntity(id: 1, name: 'Paket A');

  test('harus mengambil detail paket dari repository', () async {
    // arrange
    when(() => mockRepository.getPacket(any(), isOffline: any(named: 'isOffline')))
        .thenAnswer((_) async => Right(tPacket));

    // act
    final result = await usecase(1);

    // assert
    expect(result, Right(tPacket));
    verify(() => mockRepository.getPacket(1, isOffline: null)).called(1);
  });
}
