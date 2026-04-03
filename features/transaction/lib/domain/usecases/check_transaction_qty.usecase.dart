import 'package:core/core.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class CheckTransactionQty {
  final CashierRemoteRepository repository;

  CheckTransactionQty(this.repository);

  Future<Either<Failure, bool>> call({
    required int productId,
    required int qty,
  }) async {
    try {
      return await repository.checkTransactionQty(
        productId: productId,
        qty: qty,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
