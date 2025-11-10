// Abstract repository for landing_page_menu
import 'package:core/core.dart'; // pastikan Failure ada di core
import 'package:landing_page_menu/domain/entities/product_entity.dart';

abstract class LandingPageMenuRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
}
