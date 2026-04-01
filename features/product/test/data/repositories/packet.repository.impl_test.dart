import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/data/models/packet.model.dart';
import 'package:product/data/repositories/packet.repository.impl.dart';
import 'package:product/data/datasources/packet_local.datasource.dart';

class MockPacketLocalDataSource extends Mock implements PacketLocalDataSource {}

void main() {
  late MockPacketLocalDataSource mockLocal;
  late PacketRepositoryImpl repository;

  setUp(() {
    mockLocal = MockPacketLocalDataSource();
    repository = PacketRepositoryImpl(local: mockLocal);
    
    registerFallbackValue(PacketModel(id: 0));
  });

  group('PacketRepositoryImpl', () {
    test('getPackets harus mengambil dari lokal dan melakukan seeding jika kosong', () async {
      // Mocking getPackets (first call empty, second call with data after seeding)
      when(() => mockLocal.getPackets(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);
      when(() => mockLocal.getPackets())
          .thenAnswer((_) async => [PacketModel(id: 1, name: 'Paket 1')]);
      when(() => mockLocal.upsertPacket(any(), items: any(named: 'items')))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as PacketModel);

      final result = await repository.getPackets();

      expect(result.isRight(), true);
      result.fold((l) => fail('Seharusnya sukses'), (r) {
        expect(r.length, 1);
        expect(r.first.name, 'Paket 1');
      });
    });

    test('deletePacket harus memanggil local delete', () async {
      when(() => mockLocal.deletePacket(any())).thenAnswer((_) async => 1);

      final result = await repository.deletePacket(1);

      expect(result, const Right(true));
      verify(() => mockLocal.deletePacket(1)).called(1);
    });
  });
}
