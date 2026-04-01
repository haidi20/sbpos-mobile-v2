import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/category.entity.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:product/domain/usecases/create_product.usecase.dart';
import 'package:product/domain/usecases/update_product.usecase.dart';
import 'package:product/domain/usecases/delete_product.usecase.dart';
import 'package:product/presentation/view_models/product_management.vm.dart';

class MockGetProducts extends Mock implements GetProducts {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockUpdateProduct extends Mock implements UpdateProduct {}
class MockDeleteProduct extends Mock implements DeleteProduct {}

void main() {
  late MockGetProducts mockGet;
  late MockCreateProduct mockCreate;
  late MockUpdateProduct mockUpdate;
  late MockDeleteProduct mockDelete;
  late ProductManagementViewModel vm;

  setUp(() {
    mockGet = MockGetProducts();
    mockCreate = MockCreateProduct();
    mockUpdate = MockUpdateProduct();
    mockDelete = MockDeleteProduct();
    
    vm = ProductManagementViewModel(
      getProductsUsecase: mockGet,
      createProductUsecase: mockCreate,
      updateProductUsecase: mockUpdate,
      deleteProductUsecase: mockDelete,
    );
    
    registerFallbackValue(const ProductEntity());
  });

  group('ProductManagementViewModel', () {
    test('initial state harus benar', () {
      expect(vm.state.loading, false);
      expect(vm.state.products, isEmpty);
      expect(vm.state.activeCategory, 'All');
    });

    test('getProducts harus memperbarui state dengan daftar produk', () async {
      final products = [const ProductEntity(id: 1, name: 'Produk 1')];
      when(() => mockGet(isOffline: true)).thenAnswer((_) async => Right(products));

      await vm.getProducts();

      expect(vm.state.products, products);
      expect(vm.state.loading, false);
    });

    test('filteredProducts harus menyaring berdasarkan kategori', () {
      final p1 = const ProductEntity(id: 1, name: 'A', category: CategoryEntity(name: 'Cat 1'));
      final p2 = const ProductEntity(id: 2, name: 'B', category: CategoryEntity(name: 'Cat 2'));
      
      // Inject state manually for testing logic
      vm.state = vm.state.copyWith(products: [p1, p2]);
      
      vm.setActiveCategory('Cat 1');
      expect(vm.filteredProducts, [p1]);
      
      vm.setActiveCategory('All');
      expect(vm.filteredProducts, [p1, p2]);
    });

    test('onCreateProduct harus membersihkan draft setelah berhasil', () async {
      vm.setDraftProduct(const ProductEntity(name: 'Baru'));
      when(() => mockCreate(any(), isOffline: true))
          .thenAnswer((_) async => const Right(ProductEntity(id: 3, name: 'Baru')));

      await vm.onCreateProduct();

      expect(vm.draft.name, isNull);
      expect(vm.state.products.length, 1);
    });
  });
}
