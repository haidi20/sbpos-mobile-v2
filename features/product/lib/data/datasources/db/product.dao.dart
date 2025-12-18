import 'product.table.dart';
import 'package:core/core.dart';
import 'package:product/data/models/product.model.dart';

class ProductDao {
  final Database database;
  final _logger = Logger('ProductDao');
  final bool isShowLog = false;

  void _logInfo(String message) {
    if (isShowLog) _logger.info(message);
  }

  void _logSevere(String message, [Object? error, StackTrace? stack]) {
    if (isShowLog) _logger.severe(message, error, stack);
  }

  ProductDao(this.database);

  Future<List<ProductModel>> getProducts({int? limit, int? offset}) async {
    try {
      final rows = await database.query(ProductTable.tableName,
          limit: limit, offset: offset);
      final result = rows.map((r) => ProductModel.fromDbLocal(r)).toList();
      _logInfo('getProducts: success count=${result.length}');
      return result;
    } catch (e, s) {
      _logSevere('Error getProducts: $e', e, s);
      rethrow;
    }
  }

  Future<ProductModel?> getProductById(int id) async {
    try {
      final rows = await database.query(
        ProductTable.tableName,
        where: '${ProductTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final model = ProductModel.fromDbLocal(rows.first);
      _logInfo('getProductById: success id=$id');
      return model;
    } catch (e, s) {
      _logSevere('Error getProductById: $e', e, s);
      rethrow;
    }
  }

  Future<ProductModel?> getLatestProduct() async {
    try {
      final rows = await database.query(
        ProductTable.tableName,
        orderBy: '${ProductTable.colCreatedAt} DESC',
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final model = ProductModel.fromDbLocal(rows.first);
      _logInfo('getLatestProduct: success id=${model.id}');
      return model;
    } catch (e, s) {
      _logSevere('Error getLatestProduct: $e', e, s);
      rethrow;
    }
  }

  Future<ProductModel> insertProduct(Map<String, dynamic> product) async {
    try {
      return await database.transaction((txn) async {
        product[ProductTable.colSyncedAt] = null;
        final cleaned = Map<String, dynamic>.from(product)
          ..removeWhere((k, v) => v == null);
        final id = await txn.insert(ProductTable.tableName, cleaned);
        final inserted = await txn.query(
          ProductTable.tableName,
          where: '${ProductTable.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );
        final model = ProductModel.fromDbLocal(inserted.first);
        _logInfo('insertProduct: success id=${model.id}');
        return model;
      });
    } catch (e, s) {
      _logSevere('Error insertProduct: $e', e, s);
      rethrow;
    }
  }

  Future<ProductModel?> getProductByServerId(int idServer) async {
    try {
      final rows = await database.query(
        ProductTable.tableName,
        where: '${ProductTable.colIdServer} = ?',
        whereArgs: [idServer],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final model = ProductModel.fromDbLocal(rows.first);
      _logInfo(
          'getProductByServerId: success id_server=$idServer -> id=${model.id}');
      return model;
    } catch (e, s) {
      _logSevere('Error getProductByServerId: $e', e, s);
      rethrow;
    }
  }

  Future<ProductModel> upsertProduct(Map<String, dynamic> product) async {
    try {
      return await database.transaction((txn) async {
        final idServer = product[ProductTable.colIdServer];
        if (idServer != null) {
          final existingRows = await txn.query(
            ProductTable.tableName,
            where: '${ProductTable.colIdServer} = ?',
            whereArgs: [idServer],
            limit: 1,
          );
          if (existingRows.isNotEmpty) {
            final existing = ProductModel.fromDbLocal(existingRows.first);
            final cleaned = Map<String, dynamic>.from(product)
              ..removeWhere((k, v) => v == null);
            final id = existing.id;
            cleaned.remove('id');
            await txn.update(
              ProductTable.tableName,
              cleaned,
              where: '${ProductTable.colId} = ?',
              whereArgs: [id],
            );
            final updated = await txn.query(
              ProductTable.tableName,
              where: '${ProductTable.colId} = ?',
              whereArgs: [id],
              limit: 1,
            );
            final model = ProductModel.fromDbLocal(updated.first);
            _logInfo(
                'upsertProduct: updated id=${model.id} id_server=$idServer');
            return model;
          }
        }

        final cleaned = Map<String, dynamic>.from(product)
          ..removeWhere((k, v) => v == null);
        final newId = await txn.insert(ProductTable.tableName, cleaned);
        final inserted = await txn.query(
          ProductTable.tableName,
          where: '${ProductTable.colId} = ?',
          whereArgs: [newId],
          limit: 1,
        );
        final model = ProductModel.fromDbLocal(inserted.first);
        _logInfo(
            'upsertProduct: inserted id=${model.id} id_server=${product[ProductTable.colIdServer]}');
        return model;
      });
    } catch (e, s) {
      _logSevere('Error upsertProduct: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteProduct(int id) async {
    try {
      final res = await database.delete(
        ProductTable.tableName,
        where: '${ProductTable.colId} = ?',
        whereArgs: [id],
      );
      _logInfo('deleteProduct: success id=$id rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error deleteProduct: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearProducts() async {
    try {
      final res = await database.delete(ProductTable.tableName);
      _logInfo('clearProducts: success rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error clearProducts: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearSyncedAt(int id) async {
    try {
      final res = await database.rawUpdate(
        'UPDATE ${ProductTable.tableName} SET ${ProductTable.colSyncedAt} = NULL WHERE ${ProductTable.colId} = ?',
        [id],
      );
      _logInfo('clearSyncedAt: success id=$id rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error clearSyncedAt: $e', e, s);
      rethrow;
    }
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    try {
      final id = product['id'];
      final cleaned = Map<String, dynamic>.from(product)
        ..removeWhere((k, v) => v == null);
      cleaned.remove('id');
      final res = await database.update(
        ProductTable.tableName,
        cleaned,
        where: '${ProductTable.colId} = ?',
        whereArgs: [id],
      );
      _logInfo('updateProduct: success id=$id rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error updateProduct: $e', e, s);
      rethrow;
    }
  }

  // detail operations - optional if product has details/attributes
  // detail operations removed — product does not use details
}
