// Implementation of landing_page_menu repository
import 'package:core/core.dart';
import 'package:landing_page_menu/data/models/product_model.dart';
import 'package:landing_page_menu/domain/entities/product_entity.dart';
import 'package:landing_page_menu/domain/repositories/landing_page_menu_repository.dart';
import 'package:landing_page_menu/data/datasources/landing_page_menu_local_data_source.dart';
import 'package:landing_page_menu/data/datasources/landing_page_menu_remote_data_source.dart';

class LandingPageMenuRepositoryImpl implements LandingPageMenuRepository {
  final LandingPageMenuLocalDataSource local;
  final LandingPageMenuRemoteDataSource remote;

  static final Logger _logger = Logger('LandingPageMenuRepositoryImpl');

  LandingPageMenuRepositoryImpl({
    required this.remote,
    required this.local,
  });

  Future<List<ProductEntity>> _getLocalEntities() async {
    try {
      final localData = await local.getProducts();
      return localData.map((model) => model.toEntity()).toList();
    } catch (e, stackTrace) {
      _logger.severe(
          'Error saat mengambil data products dari local:', e, stackTrace);
      return [];
    }
  }

  Future<void> _saveToLocal(List<ProductModel>? products) async {
    try {
      if (products != null && products.isNotEmpty) {
        await local.insertSyncProducts(products: products);
      }
    } catch (e, stackTrace) {
      _logger.severe('Error saat menyimpan products ke local:', e, stackTrace);
    }
  }

  Future<Either<Failure, List<ProductEntity>>> _fallbackToLocal({
    Failure fallbackFailure = const NetworkFailure(),
  }) async {
    try {
      final localEntities = await _getLocalEntities();
      if (localEntities.isNotEmpty) {
        return Right(localEntities);
      }
      return Left(fallbackFailure);
    } catch (e, stackTrace) {
      _logger.severe('Error saat fallback ke local:', e, stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await remote.fetchProducts();

        if (response.success == true && response.data != null) {
          await _saveToLocal(response.data!);
          List<ProductEntity> entities =
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
        _logger.severe('Error saat mengambil data products:', e, stackTrace);
        return _fallbackToLocal(fallbackFailure: const UnknownFailure());
      }
    } else {
      return _fallbackToLocal(fallbackFailure: const NetworkFailure());
    }
  }
}
