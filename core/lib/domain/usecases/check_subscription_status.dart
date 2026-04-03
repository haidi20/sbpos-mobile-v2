import 'package:core/core.dart';

class CheckSubscriptionStatus {
  const CheckSubscriptionStatus(this.repository);

  final OperationalRepository repository;

  Future<Either<Failure, OperationalCheckEntity>> call() async {
    try {
      return await repository.checkSubscriptionStatus();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
