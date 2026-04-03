import 'package:core/core.dart';
import 'package:transaction/domain/entitties/ojol_option.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class GetCashierOjolOptions {
  final CashierRemoteRepository repository;

  GetCashierOjolOptions(this.repository);

  Future<Either<Failure, List<OjolOptionEntity>>> call() async {
    try {
      return await repository.getOjolOptions();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
