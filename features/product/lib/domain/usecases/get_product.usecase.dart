import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/repositories/product.repository.dart';

class GetProduct {
  final ProductRepository repository;
  GetProduct(this.repository);

  Future<Either<Failure, ProductEntity>> call(int id, {bool? isOffline}) async {
    return await repository.getProduct(id, isOffline: isOffline);
  }
}
