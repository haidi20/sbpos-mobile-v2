import 'package:core/core.dart';
import 'package:transaction/domain/entitties/edit_order_check.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class CheckEditOrder {
  final CashierRemoteRepository repository;

  CheckEditOrder(this.repository);

  Future<Either<Failure, EditOrderCheckEntity>> call(int transactionId) async {
    try {
      return await repository.checkEditOrder(transactionId);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
