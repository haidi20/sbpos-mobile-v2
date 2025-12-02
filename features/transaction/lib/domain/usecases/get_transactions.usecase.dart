import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class GetTransactionsUsecase {
  final TransactionRepository repository;

  GetTransactionsUsecase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call(
      {bool? isOffline}) async {
    return await repository.getTransactions(isOffline: isOffline);
  }
}
