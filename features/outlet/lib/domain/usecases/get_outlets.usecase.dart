import 'package:core/core.dart';
import 'package:outlet/domain/entities/outlet.entity.dart';
import 'package:outlet/domain/repositories/outlet.repository.dart';

class GetOutlets {
  final OutletRepository repository;

  GetOutlets(this.repository);

  Future<Either<Failure, List<OutletEntity>>> call() async {
    try {
      return await repository.getDataOutlets();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
