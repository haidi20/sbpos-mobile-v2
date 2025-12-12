import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts(
      {String? query, bool? isOffline});
  Future<Either<Failure, ProductEntity>> getProduct(int id, {bool? isOffline});
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product,
      {bool? isOffline});
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product,
      {bool? isOffline});
  Future<Either<Failure, bool>> deleteProduct(int id, {bool? isOffline});
}
