import 'package:core/core.dart';
import '../models/outlet_model.dart';
import '../../domain/entities/outlet_entity.dart';
import '../../domain/repositories/outlet_repository.dart';
import '../datasources/outlet_local_data_source.dart';
import '../datasources/outlet_remote_data_source.dart';

class OutletRepositoryImpl implements OutletRepository {
  final OutletRemoteDataSource remote;
  final OutletLocalDataSource local;

  static final Logger _logger = Logger('OutletRepositoryImpl');

  OutletRepositoryImpl({
    required this.remote,
    required this.local,
  });

  Future<List<OutletEntity>> _getLocalEntities() async {
    final localResp = await local.getOutlets();
    return localResp.map((model) => model.toEntity()).toList();
  }

  Future<List<OutletModel>?> _saveToLocal(List<OutletModel>? outlets) async {
    if (outlets != null && outlets.isNotEmpty) {
      final response = await local.insertSyncOutlets(outlets: outlets);
      if (response.isEmpty) {
        _logger.warning('No outlets were synchronized to local database.');
        return null;
      }

      return response;
    }
    return null;
  }

  Future<Either<Failure, List<OutletEntity>>> _fallbackToLocal({
    Failure fallbackFailure = const NetworkFailure(),
  }) async {
    final localEntities = await _getLocalEntities();
    if (localEntities.isNotEmpty) {
      return Right(localEntities);
    }
    return Left(fallbackFailure);
  }

  @override
  Future<Either<Failure, List<OutletEntity>>> getDataOutlets() async {
    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await remote.fetchOutlets();

        if (response.success == true && response.data != null) {
          final getOutlets = await _saveToLocal(response.data);

          return Right(getOutlets!.map((model) => model.toEntity()).toList());
        } else {
          return _fallbackToLocal(fallbackFailure: const ServerFailure());
        }
      } on ServerException {
        return _fallbackToLocal(fallbackFailure: const ServerFailure());
      } on NetworkException {
        return _fallbackToLocal(fallbackFailure: const NetworkFailure());
      } catch (e, stackTrace) {
        _logger.severe('Error saat mengambil data outlet:', e, stackTrace);
        return _fallbackToLocal(fallbackFailure: const UnknownFailure());
      }
    } else {
      return _fallbackToLocal(fallbackFailure: const NetworkFailure());
    }
  }
}
