import 'package:core/core.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';

class CloseCashier {
  final ShiftRepository repository;

  CloseCashier(this.repository);

  Future<Either<Failure, ShiftStatusEntity>> call(int cashInDrawer) async {
    try {
      return await repository.closeCashier(cashInDrawer);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(UnknownFailure());
    }
  }
}
