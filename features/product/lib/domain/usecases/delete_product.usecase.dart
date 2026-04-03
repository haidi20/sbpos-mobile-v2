import 'package:core/core.dart';
import 'package:product/domain/repositories/product.repository.dart';

class DeleteProduct {
  final ProductRepository repository;
  DeleteProduct(this.repository);

  Future<Either<Failure, bool>> call(int id, {bool? isOffline}) async {
    try {
      return await repository.deleteProduct(id, isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
