import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/domain/repositories/product.repository.dart';
import 'package:product/domain/usecases/delete_product.usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;
  late DeleteProduct usecase;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = DeleteProduct(mockRepository);
  });

  test('harus memanggil repository untuk menghapus produk', () async {
    // arrange
    when(() => mockRepository.deleteProduct(any(), isOffline: any(named: 'isOffline')))
        .thenAnswer((_) async => const Right(true));

    // act
    final result = await usecase(1);

    // assert
    expect(result, const Right(true));
    verify(() => mockRepository.deleteProduct(1, isOffline: null)).called(1);
  });
}
