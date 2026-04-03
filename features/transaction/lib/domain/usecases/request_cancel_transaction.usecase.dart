import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction_action.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class RequestCancelTransaction {
  final CashierRemoteRepository repository;

  RequestCancelTransaction(this.repository);

  Future<Either<Failure, TransactionActionEntity>> call({
    required int transactionId,
    required String reason,
  }) async {
    try {
      return await repository.requestCancelTransaction(
        transactionId: transactionId,
        reason: reason,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
