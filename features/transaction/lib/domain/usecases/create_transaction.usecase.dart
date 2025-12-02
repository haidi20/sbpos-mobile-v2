import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(TransactionEntity tx,
      {bool? isOffline}) async {
    return await repository.createTransaction(tx, isOffline: isOffline);
  }
}
