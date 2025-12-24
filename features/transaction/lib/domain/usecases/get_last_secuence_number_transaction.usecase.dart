import 'package:core/core.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

/// Usecase to obtain the highest `sequenceNumber` among sudah ada
/// transactions. Returns 0 when none found.
class GetLastSequenceNumberTransaction {
  final TransactionRepository repository;

  GetLastSequenceNumberTransaction(this.repository);

  Future<int> call({bool isOffline = true}) async {
    try {
      // repository exposes a local-only fast path
      final res = await repository.getLastSequenceNumber(isOffline: isOffline);
      return res.fold((_) => 0, (v) => v);
    } catch (_) {
      return 0;
    }
  }
}
