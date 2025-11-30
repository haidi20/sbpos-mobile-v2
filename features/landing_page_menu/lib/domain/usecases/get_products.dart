// Use case to get landing_page_menus
import 'package:core/core.dart';
import 'package:product/domain/entities/product_entity.dart';
import 'package:landing_page_menu/domain/repositories/landing_page_menu_repository.dart';

class GetProducts {
  final LandingPageMenuRepository repository;

  GetProducts(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call() async {
    return await repository.getProducts();
  }
}
