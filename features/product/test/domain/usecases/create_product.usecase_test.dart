import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/repositories/product.repository.dart';
import 'package:product/domain/usecases/create_product.usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;
  late CreateProduct usecase;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = CreateProduct(mockRepository);
    
    // Fallback for ProductEntity if needed by mocktail
    registerFallbackValue(const ProductEntity());
  });

  const tProduct = ProductEntity(id: 1, name: 'Produk Baru');

  test('harus memanggil repository untuk membuat produk baru', () async {
    // arrange
    when(() => mockRepository.createProduct(any(), isOffline: any(named: 'isOffline')))
        .thenAnswer((_) async => const Right(tProduct));

    // act
    final result = await usecase(tProduct);

    // assert
    expect(result, const Right(tProduct));
    verify(() => mockRepository.createProduct(tProduct, isOffline: null))
        .called(1);
  });
}
