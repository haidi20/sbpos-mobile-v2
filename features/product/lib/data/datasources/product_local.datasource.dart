import 'package:core/core.dart';
import 'package:product/data/models/product.model.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:product/data/datasources/db/product.dao.dart';

class ProductLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final Database? _testDb;
  final _logger = Logger('ProductLocalDataSource');
  final bool isShowLog = false;

  ProductLocalDataSource({Database? testDb}) : _testDb = testDb;

  void _logInfo(String msg) {
    if (isShowLog) _logger.info(msg);
  }

  void _logSevere(String msg, [Object? e, StackTrace? st]) {
    if (isShowLog) _logger.severe(msg, e, st);
  }

  Future<T> _withRetry<T>(Future<T> Function() action,
      {int retries = 3,
      Duration delay = const Duration(milliseconds: 50)}) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (_) {
        attempt++;
        if (attempt >= retries) rethrow;
        await Future.delayed(delay);
      }
    }
  }

  @visibleForTesting
  ProductDao createDao(Database? db) => ProductDao(db);

  Future<List<ProductModel>> getProducts({int? limit, int? offset}) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      // Log db selection for debugging: null => use Sembast fallback.
      _logger.info(
          'ProductLocalDataSource.getProducts: using ${db == null ? 'Sembast (web)' : 'SQL (native)'} database');
      final dao = createDao(db);
      final result = await dao.getProducts(limit: limit, offset: offset);
      _logger.info(
          'ProductLocalDataSource.getProducts: returned ${result.length} items');
      _logInfo('getProducts: count=${result.length}');
      return result;
    } catch (e, st) {
      _logSevere('Error getProducts', e, st);
      rethrow;
    }
  }

  /// Cari produk berdasarkan nama (LIKE, case-insensitive)
  Future<List<ProductModel>> searchProductsByName(String name,
      {int? limit, int? offset}) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      final result =
          await dao.searchProductsByName(name, limit: limit, offset: offset);
      _logInfo('searchProductsByName: count=${result.length}');
      return result;
    } catch (e, st) {
      _logSevere('Error searchProductsByName', e, st);
      rethrow;
    }
  }

  Future<ProductModel?> getProductById(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      return await dao.getProductById(id);
    } catch (e, st) {
      _logSevere('Error getProductById', e, st);
      rethrow;
    }
  }

  Future<ProductModel?> insertProduct(ProductModel model) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      final map = sanitizeForDb(model.toInsertDbLocal());
      final inserted =
          await _withRetry(() async => await dao.insertProduct(map));
      _logInfo('insertProduct: id=${inserted.id}');
      return inserted;
    } catch (e, st) {
      _logSevere('Error insertProduct', e, st);
      rethrow;
    }
  }

  Future<ProductModel?> upsertProduct(ProductModel model) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      final map = sanitizeForDb(model.toInsertDbLocal());
      final upserted =
          await _withRetry(() async => await dao.upsertProduct(map));
      _logInfo('upsertProduct: id=${upserted.id}');
      return upserted;
    } catch (e, st) {
      _logSevere('Error upsertProduct', e, st);
      rethrow;
    }
  }

  Future<int> updateProduct(Map<String, dynamic> data) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      final map = sanitizeForDb(Map<String, dynamic>.from(data));
      if (data.containsKey('id')) map['id'] = data['id'];
      final updated = await dao.updateProduct(map);
      _logInfo('updateProduct: rows=$updated');
      return updated;
    } catch (e, st) {
      _logSevere('Error updateProduct', e, st);
      rethrow;
    }
  }

  Future<int> deleteProduct(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      final count = await dao.deleteProduct(id);
      _logInfo('deleteProduct: rows=$count');
      return count;
    } catch (e, st) {
      _logSevere('Error deleteProduct', e, st);
      rethrow;
    }
  }

  Future<int> clearProducts() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      return await dao.clearProducts();
    } catch (e, st) {
      _logSevere('Error clearProducts', e, st);
      rethrow;
    }
  }

  Future<int> clearSyncedAt(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      final count = await dao.clearSyncedAt(id);
      _logInfo('clearSyncedAt: rows=$count');
      return count;
    } catch (e, st) {
      _logSevere('Error clearSyncedAt', e, st);
      rethrow;
    }
  }
}
