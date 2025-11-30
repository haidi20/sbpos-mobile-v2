import 'package:core/core.dart';
import 'package:product/domain/entities/product_entity.dart';

abstract class LandingPageMenuRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
}
