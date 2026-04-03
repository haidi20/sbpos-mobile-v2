import 'package:core/core.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';

class GetShiftStatus {
  final ShiftRepository repository;

  GetShiftStatus(this.repository);

  Future<Either<Failure, ShiftStatusEntity>> call() async {
    try {
      return await repository.getShiftStatus();
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(UnknownFailure());
    }
  }
}
