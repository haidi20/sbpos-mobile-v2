import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

/// Usecase untuk mengambil satu transaksi "aktif" —
/// yaitu transaksi terbaru berdasarkan `buatdAt` (descending) dan status 'Pending'.
class GetTransactionActive {
  final TransactionRepository repository;

  GetTransactionActive(this.repository);
  Future<Either<Failure, TransactionEntity>> call({bool? isOffline}) async {
    try {
      return await repository.getPendingTransaction(isOffline: isOffline);
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
