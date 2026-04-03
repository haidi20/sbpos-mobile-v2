import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction_action.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class ConfirmCancelTransaction {
  final CashierRemoteRepository repository;

  ConfirmCancelTransaction(this.repository);

  Future<Either<Failure, TransactionActionEntity>> call({
    required int transactionId,
    required String otp,
  }) async {
    try {
      return await repository.confirmCancelTransaction(
        transactionId: transactionId,
        otp: otp,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
