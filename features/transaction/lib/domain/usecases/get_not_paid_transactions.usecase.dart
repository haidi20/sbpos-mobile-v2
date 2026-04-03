import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class GetNotPaidTransactions {
  final CashierRemoteRepository repository;

  GetNotPaidTransactions(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call() async {
    try {
      return await repository.getNotPaidTransactions();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
