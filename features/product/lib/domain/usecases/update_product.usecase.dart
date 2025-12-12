import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/repositories/product.repository.dart';

class UpdateProduct {
  final ProductRepository repository;
  UpdateProduct(this.repository);

  Future<Either<Failure, ProductEntity>> call(ProductEntity product,
      {bool? isOffline}) async {
    return await repository.updateProduct(product, isOffline: isOffline);
  }
}
