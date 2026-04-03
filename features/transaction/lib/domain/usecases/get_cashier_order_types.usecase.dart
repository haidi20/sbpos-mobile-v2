import 'package:core/core.dart';
import 'package:transaction/domain/entitties/order_type.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class GetCashierOrderTypes {
  final CashierRemoteRepository repository;

  GetCashierOrderTypes(this.repository);

  Future<Either<Failure, List<OrderTypeEntity>>> call() async {
    try {
      return await repository.getOrderTypes();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
