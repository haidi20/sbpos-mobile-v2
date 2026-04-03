import 'package:core/core.dart';

class CheckServiceStatus {
  const CheckServiceStatus(this.repository);

  final OperationalRepository repository;

  Future<Either<Failure, OperationalCheckEntity>> call() async {
    try {
      return await repository.checkServiceStatus();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
