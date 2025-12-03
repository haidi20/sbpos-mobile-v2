import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class GetTransactionsOffline {
  final TransactionRepository repository;

  GetTransactionsOffline(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call() async {
    return await repository.getTransactions(isOffline: true);
  }
}
