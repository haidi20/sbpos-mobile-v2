import 'package:core/core.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
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
