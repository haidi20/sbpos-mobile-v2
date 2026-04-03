import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class CheckoutTransaction {
  final CashierRemoteRepository repository;

  CheckoutTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction, {
    required bool isOnline,
  }) async {
    try {
      return await repository.checkoutTransaction(
        transaction,
        isOnline: isOnline,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
