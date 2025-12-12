import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/repositories/product.repository.dart';

class CreateProduct {
  final ProductRepository repository;
  CreateProduct(this.repository);

  Future<Either<Failure, ProductEntity>> call(ProductEntity product,
      {bool? isOffline}) async {
    return await repository.createProduct(product, isOffline: isOffline);
  }
}
