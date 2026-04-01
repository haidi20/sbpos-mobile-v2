import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:product/presentation/controllers/packet_management.controller.dart';
import 'package:product/presentation/view_models/packet_management.vm.dart';
import 'package:product/presentation/view_models/packet_management.state.dart';
import 'package:product/presentation/providers/product.provider.dart';
import 'package:product/presentation/providers/packet.provider.dart';

class MockGetProducts extends Mock implements GetProducts {}

class FakePacketManagementViewModel extends StateNotifier<PacketManagementState> implements PacketManagementViewModel {
  FakePacketManagementViewModel() : super(PacketManagementState());
  
  PacketEntity _draft = PacketEntity();
  @override
  PacketEntity get draft => _draft;
  
  @override
  void setDraft(PacketEntity packet) {
    _draft = packet;
  }

  @override
  Future<void> getPackets() async {}
  @override
  Future<void> onCreatePacket() async {}
  @override
  Future<void> onUpdatePacket() async {}

  @override
  Future<void> Function()? get onAfterCrud => null;
  
  @override
  Future<bool> onDeletePacketById(int? id) async => true;

  @override
  Map<int, int> get selectedMap => {};
  @override
  Set<int> get selectedIds => {};
  @override
  void setIsForm(bool v) {}
  @override
  void setSearchQuery(String q) {}
  @override
  void initSelectionFromPacket(PacketEntity packet) {}
  @override
  bool isSelected(int productId) => false;
  @override
  int qtyFor(int productId, [int fallback = 1]) => fallback;
  @override
  void toggleSelected(int productId) {}
  @override
  void incrementQty(int productId) {}
  @override
  void decrementQty(int productId) {}
  @override
  Future<List<ProductEntity>> resolveProducts(List<ProductEntity> products) async => [];
  @override
  void addDraftItem(PacketItemEntity item) {}
  @override
  void updateDraftItemAt(int index, PacketItemEntity item) {}
  @override
  void removeDraftItemAt(int index) {}
  @override
  int computeTotal({int basePrice = 0, bool applyPacketDiscount = false, int packetDiscount = 0}) => 0;
  @override
  int findProductPrice(int? productId) => 0;
  @override
  Future<void> ensureProductsLoaded() async {}
}

void main() {
  late MockGetProducts mockGetProducts;
  late FakePacketManagementViewModel fakeVM;

  setUpAll(() {
    registerFallbackValue(PacketEntity());
  });

  setUp(() {
    mockGetProducts = MockGetProducts();
    fakeVM = FakePacketManagementViewModel();

    when(() => mockGetProducts(isOffline: any(named: 'isOffline')))
        .thenAnswer((_) async => const Right([]));
  });

  testWidgets('computeItemSubtotal calculates correctly', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        productGetProductsProvider.overrideWithValue(mockGetProducts),
        packetManagementViewModelProvider.overrideWith((ref) => fakeVM),
      ],
      child: MaterialApp(
        home: Consumer(builder: (context, ref, _) {
          final controller = PacketManagementController(ref);
          controller.products.value = const [ProductEntity(id: 1, price: 1000.0)];

          final subtotal = controller.computeItemSubtotal(productId: 1, qty: 2, discount: 500);
          expect(subtotal, 1500);
          
          return const SizedBox.shrink();
        }),
      ),
    ));
  });

  testWidgets('init should populate controllers from packet entity', (tester) async {
    final packet = PacketEntity(id: 1, name: 'Paket Promo', price: 50000);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        productGetProductsProvider.overrideWithValue(mockGetProducts),
        packetManagementViewModelProvider.overrideWith((ref) => fakeVM),
      ],
      child: MaterialApp(
        home: Consumer(builder: (context, ref, _) {
          final controller = PacketManagementController(ref);
          controller.init(packet: packet);
          
          expect(controller.nameCtrl.text, 'Paket Promo');
          expect(controller.priceCtrl.text, '50000');
          
          return const SizedBox.shrink();
        }),
      ),
    ));
  });
}
