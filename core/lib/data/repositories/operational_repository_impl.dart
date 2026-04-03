import 'package:core/core.dart';
import 'package:core/data/datasources/operational_remote_data_source.dart';

class OperationalRepositoryImpl implements OperationalRepository {
  OperationalRepositoryImpl({
    required this.remote,
  });

  final OperationalRemoteDataSource remote;
  final Logger _logger = Logger('OperationalRepositoryImpl');

  @override
  Future<Either<Failure, OperationalCheckEntity>> checkServiceStatus() async {
    try {
      final response = await remote.checkServiceStatus();
      if (!response.success) {
        return Left(
          ServerValidation(
            response.message.isEmpty
                ? 'Gagal memeriksa status layanan'
                : response.message,
          ),
        );
      }

      return Right(
        OperationalCheckEntity(
          isAllowed: response.isAllowed,
          message: response.message,
        ),
      );
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Unexpected error on checkServiceStatus', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, OperationalCheckEntity>>
      checkSubscriptionStatus() async {
    try {
      final response = await remote.checkSubscriptionStatus();
      if (!response.success) {
        return Left(
          ServerValidation(
            response.message.isEmpty
                ? 'Gagal memeriksa status langganan'
                : response.message,
          ),
        );
      }

      return Right(
        OperationalCheckEntity(
          isAllowed: response.isAllowed,
          message: response.message,
        ),
      );
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Unexpected error on checkSubscriptionStatus', e, st);
      return const Left(UnknownFailure());
    }
  }
}
