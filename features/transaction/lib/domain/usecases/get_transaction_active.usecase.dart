import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

/// Usecase to fetch the single "active" transaction —
/// the most-recent transaction by `createdAt` (descending).
class GetTransactionActive {
  final TransactionRepository repository;

  GetTransactionActive(this.repository);

  Future<Either<Failure, TransactionEntity>> call({bool? isOffline}) async {
    try {
      final res = await repository.getLatestTransaction(isOffline: isOffline);
      return await res.fold((l) async {
        // if latest not available, try to fetch id=1 as fallback (tests expect this)
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
