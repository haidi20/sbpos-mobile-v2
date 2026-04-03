import 'package:core/core.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';

class OpenCashier {
  final ShiftRepository repository;

  OpenCashier(this.repository);

  Future<Either<Failure, ShiftStatusEntity>> call(int initialBalance) async {
    try {
      return await repository.openCashier(initialBalance);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(UnknownFailure());
    }
  }
}
