import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:warehouse/data/models/warehouse_model.dart';
import 'package:warehouse/data/datasources/db/warehouse.dao.dart';

class WarehouseLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final _logger = Logger('WarehouseLocalDataSource');

  Future<List<WarehouseModel>> getWarehouses() async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning("Database gagal dibuka/null");
        return [];
      }
      final query = WarehouseDao(db);

      final result = await query.getWarehouses();

      return result;
    } catch (e, st) {
      _logger.severe('Error getWarehouses', e, st);
      return [];
    }
  }

  Future<WarehouseModel?> insertDataWarehouse(
    WarehouseModel insertWarehouse,
  ) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning("Database gagal dibuka/null");
        return null;
      }
      final query = WarehouseDao(db);

      final insertedWarehouse =
          await query.insertWarehouse(insertWarehouse.toInsertDbLocal());

      return insertedWarehouse;
    } catch (e, st) {
      _logger.severe('Error insertDataWarehouse', e, st);
      rethrow;
    }
  }

  Future<List<WarehouseModel>> insertSyncWarehouses({
    required List<WarehouseModel>? warehouses,
  }) async {
    if (warehouses == null || warehouses.isEmpty) return [];

    try {
      final now = DateTime.now();

      final dbEntities = warehouses.map((e) {
        final modelWithSync = e.copyWith(syncedAt: now);
        return modelWithSync.toInsertDbLocal();
      }).toList();

      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning("Database gagal dibuka/null");
        return [];
      }
      final query = WarehouseDao(db);
      final result = await query.insertSyncWarehouses(dbEntities);

      return result;
    } catch (e, st) {
      _logger.severe('Error insertSyncWarehouses', e, st);
      return [];
    }
  }

  Future<int> deleteAllWarehouses({
    required int id,
  }) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning("Database gagal dibuka/null");
        return 0;
      }
      final query = WarehouseDao(db);
      final result = await query.deleteWarehouse(id);

      return result;
    } catch (e, st) {
      _logger.severe('Error deleteAllWarehouses', e, st);
      rethrow;
    }
  }
}
