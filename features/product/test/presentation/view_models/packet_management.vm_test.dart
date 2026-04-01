import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/domain/usecases/get_packets.usecase.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:product/domain/usecases/create_packet.usecase.dart';
import 'package:product/domain/usecases/update_packet.usecase.dart';
import 'package:product/domain/usecases/delete_packet.usecase.dart';
import 'package:product/presentation/view_models/packet_management.vm.dart';

class MockGetPackets extends Mock implements GetPackets {}
class MockGetProducts extends Mock implements GetProducts {}
class MockCreatePacket extends Mock implements CreatePacket {}
class MockUpdatePacket extends Mock implements UpdatePacket {}
class MockDeletePacket extends Mock implements DeletePacket {}

void main() {
  late MockGetPackets mockGetPackets;
  late MockGetProducts mockGetProducts;
  late MockCreatePacket mockCreatePacket;
  late MockUpdatePacket mockUpdatePacket;
  late MockDeletePacket mockDeletePacket;
  late PacketManagementViewModel vm;

  setUp(() {
    mockGetPackets = MockGetPackets();
    mockGetProducts = MockGetProducts();
    mockCreatePacket = MockCreatePacket();
    mockUpdatePacket = MockUpdatePacket();
    mockDeletePacket = MockDeletePacket();

    vm = PacketManagementViewModel(
      getPacketsUsecase: mockGetPackets,
      getProductsUsecase: mockGetProducts,
      createPacketUsecase: mockCreatePacket,
      updatePacketUsecase: mockUpdatePacket,
      deletePacketUsecase: mockDeletePacket,
    );
    
    registerFallbackValue(PacketEntity());
  });

  group('PacketManagementViewModel', () {
    test('computeTotal harus menghitung total berdasarkan draft item', () {
      final item = PacketItemEntity(productId: 1, qty: 2, subtotal: 20000);
      vm.addDraftItem(item);
      
      final total = vm.computeTotal(basePrice: 5000);
      
      // Total = 20000 + 5000 = 25000
      expect(total, 25000);
    });

    test('addDraftItem harus menambah item ke dalam draft', () {
      final item = PacketItemEntity(productName: 'Item X');
      vm.addDraftItem(item);
      
      expect(vm.draft.items?.length, 1);
      expect(vm.draft.items?.first.productName, 'Item X');
    });

    test('getPackets harus memuat data dari usecase', () async {
      final packets = [PacketEntity(id: 1, name: 'Paket 1')];
      when(() => mockGetPackets(isOffline: true)).thenAnswer((_) async => Right(packets));

      await vm.getPackets();

      expect(vm.state.packets, packets);
    });
  });
}
