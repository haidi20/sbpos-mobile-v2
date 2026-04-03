import 'package:core/core.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';

class GetLatestShift {
  const GetLatestShift(this.repository);

  final ShiftRepository repository;

  Future<Either<Failure, ShiftEntity?>> call() async {
    try {
      return await repository.getLatestShift();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
