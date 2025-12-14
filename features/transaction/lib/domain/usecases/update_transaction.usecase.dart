import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(TransactionEntity tx,
      {bool? isOffline}) async {
    try {
      return await repository.updateTransaction(tx, isOffline: isOffline);
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
