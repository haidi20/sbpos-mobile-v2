import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

/// Usecase to fetch the single "active" transaction —
/// the most-recent transaction by `createdAt` (descending).
class GetTransactionActive {
  final TransactionRepository repository;

  GetTransactionActive(this.repository);

  Future<Either<Failure, TransactionEntity>> call({bool? isOffline}) async {
    return await repository.getLatestTransaction(isOffline: isOffline);
  }
}
