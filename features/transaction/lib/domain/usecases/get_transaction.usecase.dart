import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class GetTransaction {
  final TransactionRepository repository;

  GetTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(int id,
      {bool? isOffline}) async {
    return await repository.getTransaction(id, isOffline: isOffline);
  }
}
