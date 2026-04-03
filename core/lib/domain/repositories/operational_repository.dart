import 'package:core/core.dart';

abstract class OperationalRepository {
  Future<Either<Failure, OperationalCheckEntity>> checkServiceStatus();

  Future<Either<Failure, OperationalCheckEntity>> checkSubscriptionStatus();
}
