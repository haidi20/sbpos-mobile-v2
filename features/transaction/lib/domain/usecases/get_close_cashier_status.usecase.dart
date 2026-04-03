import 'package:core/core.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';

class GetCloseCashierStatus {
  final ShiftRepository repository;

  GetCloseCashierStatus(this.repository);

  Future<Either<Failure, CloseCashierStatusEntity>> call() async {
    try {
      return await repository.getCloseCashierStatus();
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(UnknownFailure());
    }
  }
}
