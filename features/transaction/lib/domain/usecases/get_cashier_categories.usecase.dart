import 'package:core/core.dart';
import 'package:transaction/domain/entitties/cashier_category.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class GetCashierCategories {
  final CashierRemoteRepository repository;

  GetCashierCategories(this.repository);

  Future<Either<Failure, List<CashierCategoryEntity>>> call() async {
    try {
      return await repository.getCustomCategories();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
