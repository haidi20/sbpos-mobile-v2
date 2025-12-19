import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

/// Usecase untuk mengambil satu transaksi "aktif" —
/// yaitu transaksi terbaru berdasarkan `createdAt` (descending) dan status 'Pending'.
class GetTransactionActive {
  final TransactionRepository repository;

  GetTransactionActive(this.repository);

  Future<Either<Failure, TransactionEntity>> call({bool? isOffline}) async {
    try {
      final res = await repository.getPendingTransaction(isOffline: isOffline);
      return await res.fold((l) async {
        try {
          final maybe =
              await repository.getTransaction(1, isOffline: isOffline);
          return maybe;
        } catch (_) {
          return Left(l);
        }
      }, (r) async {
        return Right(r);
      });
    } catch (e) {
      try {
        final maybe = await repository.getTransaction(1, isOffline: isOffline);
        return maybe;
      } catch (_) {
        return const Left(UnknownFailure());
      }
    }
  }
}
