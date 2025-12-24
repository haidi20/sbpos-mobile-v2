import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(TransactionEntity tx,
      {bool? isOffline}) async {
    // Pastikan transaksi yang baru dibuat ditandai sebagai pending secara default.
    final txWithPending = tx.copyWith(status: TransactionStatus.pending);
    try {
      return await repository.createTransaction(txWithPending,
          isOffline: isOffline);
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
