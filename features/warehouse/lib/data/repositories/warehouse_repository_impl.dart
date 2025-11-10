import 'package:core/core.dart';
import 'package:warehouse/data/models/warehouse_model.dart';
import 'package:warehouse/domain/entities/warehouse_entity.dart';
import 'package:warehouse/domain/repositories/warehouse_repository.dart';
import 'package:warehouse/data/datasources/warehouse_local_data_source.dart';
import 'package:warehouse/data/datasources/warehouse_remote_data_source.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final WarehouseRemoteDataSource remote;
  final WarehouseLocalDataSource local;

  static final Logger _logger = Logger('WarehouseRepositoryImpl');

  WarehouseRepositoryImpl({
    required this.remote,
    required this.local,
  });

  Future<List<WarehouseEntity>> _getLocalEntities() async {
    final localData = await local.getWarehouses();
    return localData.map((model) => model.toEntity()).toList();
  }

  Future<void> _saveToLocal(List<WarehouseModel>? warehouses) async {
    if (warehouses != null && warehouses.isNotEmpty) {
      await local.insertSyncWarehouses(warehouses: warehouses);
    }
  }

  Future<Either<Failure, List<WarehouseEntity>>> _fallbackToLocal({
    Failure fallbackFailure = const NetworkFailure(),
  }) async {
    final localEntities = await _getLocalEntities();
    if (localEntities.isNotEmpty) {
      return Right(localEntities);
    }
    return Left(fallbackFailure);
  }

  @override
  Future<Either<Failure, List<WarehouseEntity>>> getDataWarehouses() async {
    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await remote.fetchWarehouses();

        if (response.success == true && response.data != null) {
          await _saveToLocal(response.data);
          final entities =
              response.data!.map((model) => model.toEntity()).toList();
          return Right(entities);
        } else {
          return _fallbackToLocal(fallbackFailure: const ServerFailure());
        }
      } on ServerException {
        return _fallbackToLocal(fallbackFailure: const ServerFailure());
      } on NetworkException {
        return _fallbackToLocal(fallbackFailure: const NetworkFailure());
      } catch (e, stackTrace) {
        _logger.severe('Error saat mengambil data warehouse:', e, stackTrace);
        return _fallbackToLocal(fallbackFailure: const UnknownFailure());
      }
    } else {
      // Offline → coba ambil dari local, jika tidak ada → NetworkFailure
      return _fallbackToLocal(fallbackFailure: const NetworkFailure());
    }
  }
}
