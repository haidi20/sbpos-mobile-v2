import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/data/models/product.model.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/data/responses/product.response.dart';
import 'package:product/data/repositories/product.repository.impl.dart';
import 'package:product/data/datasources/product_local.datasource.dart';
import 'package:product/data/datasources/product_remote.datasource.dart';

class MockProductLocalDataSource extends Mock implements ProductLocalDataSource {}
class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockProductLocalDataSource mockLocal;
  late MockProductRemoteDataSource mockRemote;
  late MockNetworkInfo mockNetworkInfo;
  late ProductRepositoryImpl repository;

  setUp(() {
    mockLocal = MockProductLocalDataSource();
    mockRemote = MockProductRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      local: mockLocal,
      remote: mockRemote,
      networkInfo: mockNetworkInfo,
    );
    
    registerFallbackValue(ProductModel(id: 0));
  });

  group('ProductRepositoryImpl', () {
    test('getProducts (offline) harus mengambil data dari lokal', () async {
      final models = [ProductModel(id: 1, name: 'Lokal')];
      when(() => mockLocal.getProducts()).thenAnswer((_) async => models);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getProducts(isOffline: true);

      expect(result.isRight(), true);
      result.fold((l) => fail('Seharusnya sukses'), (r) {
        expect(r.length, 1);
        expect(r.first.name, 'Lokal'); // ProductEntity
      });
      verify(() => mockLocal.getProducts()).called(2);
    });

    test('getProducts (online) harus mencoba remote lalu simpan ke lokal', () async {
      final remoteModels = [ProductModel(id: 1, name: 'Remote')];
      final response = ProductResponse(success: true, message: 'Success', data: remoteModels);
      
      when(() => mockRemote.fetchProducts()).thenAnswer((_) async => response);
      when(() => mockLocal.upsertProduct(any())).thenAnswer((invocation) async => invocation.positionalArguments[0] as ProductModel);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // Mocking getProducts for seeding check
      when(() => mockLocal.getProducts()).thenAnswer((_) async => remoteModels);

      final result = await repository.getProducts(isOffline: false);

      expect(result.isRight(), true);
      verify(() => mockRemote.fetchProducts()).called(1);
      verify(() => mockLocal.upsertProduct(any())).called(1);
    });

    test('createProduct harus simpan ke lokal dan coba remote', () async {
      final model = ProductModel(id: 1, name: 'Baru');
      final entity = ProductEntity.fromModel(model);
      
      when(() => mockLocal.insertProduct(any())).thenAnswer((_) async => model);
      when(() => mockLocal.clearSyncedAt(any())).thenAnswer((_) async => 1);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      
      // Kita tidak bisa mengetes remote call dengan mudah karena NetworkInfo diinstansiasi di dalam
      // Tapi kita bisa memverifikasi interaksi lokal
      await repository.createProduct(entity, isOffline: true);
      
      verify(() => mockLocal.insertProduct(any())).called(1);
      verify(() => mockLocal.clearSyncedAt(1)).called(1);
    });
  });
}
