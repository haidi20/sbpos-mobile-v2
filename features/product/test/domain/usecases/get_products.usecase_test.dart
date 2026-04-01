import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/repositories/product.repository.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;
  late GetProducts usecase;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = GetProducts(mockRepository);
  });

  final tProducts = [
    const ProductEntity(id: 1, name: 'Produk A'),
    const ProductEntity(id: 2, name: 'Produk B'),
  ];

  test('harus mengambil daftar produk dari repository', () async {
    // arrange
    when(() => mockRepository.getProducts(query: any(named: 'query'), isOffline: any(named: 'isOffline')))
        .thenAnswer((_) async => Right(tProducts));

    // act
    final result = await usecase();

    // assert
    expect(result, Right(tProducts));
    verify(() => mockRepository.getProducts(query: null, isOffline: null))
        .called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('harus mengembalikan Failure jika repository gagal', () async {
    // arrange
    when(() => mockRepository.getProducts(query: any(named: 'query'), isOffline: any(named: 'isOffline')))
        .thenAnswer((_) async => const Left(ServerFailure()));

    // act
    final result = await usecase();

    // assert
    expect(result, const Left(ServerFailure()));
  });
}
