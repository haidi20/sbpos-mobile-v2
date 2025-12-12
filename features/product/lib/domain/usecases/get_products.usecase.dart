import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/repositories/product.repository.dart';

class GetProducts {
  final ProductRepository repository;
  GetProducts(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call(
      {String? query, bool? isOffline}) async {
    return await repository.getProducts(query: query, isOffline: isOffline);
  }
}
