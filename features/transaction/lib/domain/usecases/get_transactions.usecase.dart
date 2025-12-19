import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class GetTransactionsUsecase {
  final TransactionRepository repository;

  GetTransactionsUsecase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call(
      {bool isOffline = false, QueryGetTransactions? query}) async {
    try {
      final res = await repository.getTransactions(
        query: query,
        isOffline: isOffline,
      );

      return res.map((list) {
        list.sort((a, b) {
          final aMs = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bMs = b.createdAt?.millisecondsSinceEpoch ?? 0;
          final cmp = bMs.compareTo(aMs);
          if (cmp != 0) return cmp;
          final aSeq = a.sequenceNumber;
          final bSeq = b.sequenceNumber;
          return bSeq.compareTo(aSeq);
        });
        return list;
      });
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
