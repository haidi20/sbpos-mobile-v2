import 'package:core/core.dart';
// packet seeding moved to packet repository
import 'package:product/data/models/product.model.dart';
import 'package:product/data/dummies/product.dummy.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/data/responses/product.response.dart';
import 'package:product/domain/repositories/product.repository.dart';
import 'package:product/data/datasources/product_local.datasource.dart';
import 'package:product/data/datasources/product_remote.datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource local;
  final ProductRemoteDataSource remote;

  static final Logger _logger = Logger('ProductRepositoryImpl');

  ProductRepositoryImpl({required this.remote, required this.local});

  Future<List<ProductEntity>> _getLocalEntities() async {
    final localResp = await local.getProducts();
    return localResp.map((m) => ProductEntity.fromModel(m)).toList();
  }

  Future<List<ProductModel>?> _saveToLocal(List<ProductModel>? products) async {
    if (products != null && products.isNotEmpty) {
      final inserted = <ProductModel>[];
      for (final p in products) {
        try {
          final ins = await local.insertProduct(p);
          if (ins != null) {
            inserted.add(ins);
          }
        } catch (e, st) {
          _logger.warning('Gagal insert product lokal: $e', e, st);
        }
      }
      if (inserted.isEmpty) {
        return null;
      }
      return inserted;
    }
    return null;
  }

  Future<void> _ensureSeededLocal() async {
    try {
      final localResp = await local.getProducts();
      if (localResp.isEmpty) {
        // seed products from dummy data
        try {
          final models = initialProducts.map((e) => e.toModel()).toList();
          await _saveToLocal(models);
        } catch (e, st) {
          _logger.warning('Gagal seed product lokal: $e', e, st);
        }
      }
    } catch (e, st) {
      _logger.warning('Gagal cek/seed product lokal: $e', e, st);
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts(
      {String? query, bool? isOffline}) async {
    if (isOffline == true) {
      await _ensureSeededLocal();
      final localEntities = await _getLocalEntities();
      return Right(localEntities);
    }

    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final resp = await remote.fetchProducts();
        if (resp.success != true || resp.data == null) {
          final local = await _getLocalEntities();
          if (local.isNotEmpty) {
            return Right(local);
          }
          return const Left(ServerFailure());
        }
        final models = resp.data!;
        if (models.isNotEmpty) {
          final saved = await _saveToLocal(models);
          return Right(saved!.map((m) => ProductEntity.fromModel(m)).toList());
        }
        final local = await _getLocalEntities();
        if (local.isNotEmpty) {
          return Right(local);
        }
        return const Left(ServerFailure());
      } on ServerException {
        final local = await _getLocalEntities();
        if (local.isNotEmpty) {
          return Right(local);
        }
        return const Left(ServerFailure());
      } on NetworkException {
        final local = await _getLocalEntities();
        if (local.isNotEmpty) {
          return Right(local);
        }
        return const Left(NetworkFailure());
      } catch (e, st) {
        _logger.severe('Error saat mengambil data product:', e, st);
        final local = await _getLocalEntities();
        if (local.isNotEmpty) {
          return Right(local);
        }
        return const Left(UnknownFailure());
      }
    } else {
      final local = await _getLocalEntities();
      if (local.isNotEmpty) {
        return Right(local);
      }
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(int id,
      {bool? isOffline}) async {
    if (isOffline == true) {
      final localModel = await local.getProductById(id);
      if (localModel != null) {
        return Right(ProductEntity.fromModel(localModel));
      }
      return const Left(UnknownFailure());
    }

    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      final localModel = await local.getProductById(id);
      if (localModel != null) {
        return Right(ProductEntity.fromModel(localModel));
      }
      return const Left(NetworkFailure());
    }

    try {
      final resp = await remote.getProduct(id);
      if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
        final localModel = await local.getProductById(id);
        if (localModel != null) {
          return Right(ProductEntity.fromModel(localModel));
        }
        return const Left(ServerFailure());
      }
      final model = resp.data!.first;
      await local.insertProduct(model);
      return Right(ProductEntity.fromModel(model));
    } on ServerException {
      final localModel = await local.getProductById(id);
      if (localModel != null) {
        return Right(ProductEntity.fromModel(localModel));
      }
      return const Left(ServerFailure());
    } on NetworkException {
      final localModel = await local.getProductById(id);
      if (localModel != null) {
        return Right(ProductEntity.fromModel(localModel));
      }
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan saat mengambil product:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product,
      {bool? isOffline}) async {
    try {
      final model = product.toModel();
      final localInserted = await local.insertProduct(model);
      if (localInserted == null) {
        return const Left(UnknownFailure());
      }

      if (isOffline == true) {
        final localId = localInserted.id;
        if (localId != null) {
          await local.clearSyncedAt(localId);
        }
        return Right(ProductEntity.fromModel(localInserted));
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        final localId = localInserted.id;
        if (localId != null) {
          await local.clearSyncedAt(localId);
        }
        return Right(ProductEntity.fromModel(localInserted));
      }

      try {
        final ProductResponse resp = await remote.postProduct(model.toJson());
        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          final localId = localInserted.id;
          if (localId != null) {
            await local.clearSyncedAt(localId);
          }
          return Right(ProductEntity.fromModel(localInserted));
        }
        final created = resp.data!.first;
        final syncAt = DateTime.now();
        final idServer = created.idServer ?? created.id;
        await local.updateProduct({
          'id': localInserted.id,
          'id_server': idServer,
          'synced_at': syncAt.toIso8601String(),
        });
        final updatedLocal = await local.getProductById(localInserted.id ?? 0);
        return Right(ProductEntity.fromModel(updatedLocal ?? localInserted));
      } on ServerException {
        final localId = localInserted.id;
        if (localId != null) {
          await local.clearSyncedAt(localId);
        }
        return Right(ProductEntity.fromModel(localInserted));
      } on NetworkException {
        final localId = localInserted.id;
        if (localId != null) {
          await local.clearSyncedAt(localId);
        }
        return Right(ProductEntity.fromModel(localInserted));
      }
    } catch (e, st) {
      _logger.severe('Error saat menyimpan product:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product,
      {bool? isOffline}) async {
    try {
      final model = product.toModel();
      if (model.id == null) {
        return await createProduct(product, isOffline: isOffline);
      }

      final mapForUpdate = Map<String, dynamic>.from(model.toInsertDbLocal())
        ..['id'] = model.id;

      try {
        final updateCount = await local.updateProduct(mapForUpdate);
        if (updateCount == 0) {
          return await createProduct(product, isOffline: isOffline);
        }
      } catch (e, st) {
        _logger.warning(
            'updateProduct: error updating local, fallback to create', e, st);
        return await createProduct(product, isOffline: isOffline);
      }

      if (isOffline == true) {
        if (model.id != null) {
          await local.clearSyncedAt(model.id!);
        }
        final localProd = await local.getProductById(model.id!);
        if (localProd == null) {
          return await createProduct(product, isOffline: true);
        }
        return Right(ProductEntity.fromModel(localProd));
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        if (model.id != null) {
          await local.clearSyncedAt(model.id!);
        }
        final localProd = await local.getProductById(model.id!);
        if (localProd == null) {
          return const Left(NetworkFailure());
        }
        return Right(ProductEntity.fromModel(localProd));
      }

      try {
        final resp = await remote.updateProduct(model.id ?? 0, model.toJson());
        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          if (model.id != null) {
            await local.clearSyncedAt(model.id!);
          }
          final localProd = await local.getProductById(model.id!);
          if (localProd == null) {
            return const Left(ServerFailure());
          }
          return Right(ProductEntity.fromModel(localProd));
        }
        final updatedLocal = await local.getProductById(model.id!);
        if (updatedLocal == null) {
          return const Left(UnknownFailure());
        }
        return Right(ProductEntity.fromModel(updatedLocal));
      } on ServerException {
        if (model.id != null) {
          await local.clearSyncedAt(model.id!);
        }
        final localProd = await local.getProductById(model.id!);
        if (localProd == null) {
          return const Left(ServerFailure());
        }
        return Right(ProductEntity.fromModel(localProd));
      } on NetworkException {
        if (model.id != null) {
          await local.clearSyncedAt(model.id!);
        }
        final localProd = await local.getProductById(model.id!);
        if (localProd == null) {
          return const Left(NetworkFailure());
        }
        return Right(ProductEntity.fromModel(localProd));
      }
    } catch (e, st) {
      _logger.severe('Kesalahan saat memperbarui product:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(int id, {bool? isOffline}) async {
    try {
      await local.deleteProduct(id);
      if (isOffline == true) {
        return const Right(true);
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Right(true);
      }

      try {
        final resp = await remote.deleteProduct(id);
        if (resp.success == true) {
          return const Right(true);
        }
        return const Right(true);
      } on ServerException {
        return const Right(true);
      } on NetworkException {
        return const Right(true);
      }
    } catch (e, st) {
      _logger.severe('Kesalahan saat menghapus product:', e, st);
      return const Left(UnknownFailure());
    }
  }
}
