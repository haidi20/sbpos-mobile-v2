import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class GetTransactionsUsecase {
  final TransactionRepository repository;

  GetTransactionsUsecase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call(
      {bool isOffline = false}) async {
    try {
      return await repository.getTransactions(isOffline: isOffline);
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
