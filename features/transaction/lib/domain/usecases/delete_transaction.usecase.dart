import 'package:core/core.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<Either<Failure, bool>> call(int id, {bool? isOffline}) async {
    return await repository.deleteTransaction(id, isOffline: isOffline);
  }
}
