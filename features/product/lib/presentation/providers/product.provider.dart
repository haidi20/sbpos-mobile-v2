import 'package:core/core.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:product/domain/usecases/create_product.usecase.dart';
import 'package:product/domain/usecases/update_product.usecase.dart';
import 'package:product/domain/usecases/get_product.usecase.dart';
import 'package:product/domain/usecases/delete_product.usecase.dart';
import 'package:product/presentation/view_models/product_management.vm.dart';
import 'package:product/presentation/view_models/product_management.state.dart';
import 'package:product/presentation/providers/product_repository.provider.dart';

/// Provider that exposes the `GetProducts` usecase wired to the
/// `productRepositoryProvider`. Override `productRepositoryProvider` in the
/// app composition root with a concrete repository implementation.
final productGetProductsProvider = Provider<GetProducts>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  // Intentionally allow runtime error when repository is not provided by
  // composition root — this surfaces a clear message during app wiring.
  return GetProducts(repo!);
});

final productCreateProductProvider = Provider<CreateProduct>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return CreateProduct(repo!);
});

final productUpdateProductProvider = Provider<UpdateProduct>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return UpdateProduct(repo!);
});

final productDeleteProductProvider = Provider<DeleteProduct>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return DeleteProduct(repo!);
});

final productGetProductProvider = Provider<GetProduct>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return GetProduct(repo!);
});

final productManagementViewModelProvider =
    StateNotifierProvider<ProductManagementViewModel, ProductManagementState>(
        (ref) {
  final get = ref.watch(productGetProductsProvider);
  final create = ref.watch(productCreateProductProvider);
  final update = ref.watch(productUpdateProductProvider);
  final delete = ref.watch(productDeleteProductProvider);
  return ProductManagementViewModel(
    getProductsUsecase: get,
    createProductUsecase: create,
    updateProductUsecase: update,
    deleteProductUsecase: delete,
  );
});
