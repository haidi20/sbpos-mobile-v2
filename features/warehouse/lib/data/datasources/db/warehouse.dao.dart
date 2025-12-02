import 'warehouse.table.dart';
import 'package:core/core.dart';
import 'package:warehouse/data/models/warehouse_model.dart';

class WarehouseDao {
  final Database database;
  final _logger = Logger('WarehouseDao');

  WarehouseDao(this.database);

  Future<List<WarehouseModel>> getWarehouses() async {
    try {
      final result = await database.query(WarehouseTable.tableName);
      return result.map((e) => WarehouseModel.fromDbLocal(e)).toList();
    } catch (e, s) {
      _logger.severe('Error getWarehouses: $e', e, s);
      rethrow;
    }
  }

  Future<WarehouseModel?> getWarehouseById(int id) async {
    try {
      final results = await database.query(
        WarehouseTable.tableName,
        where: '${WarehouseTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isNotEmpty) {
        return WarehouseModel.fromDbLocal(results.first);
      }
      return null;
    } catch (e, s) {
      _logger.severe('Error getWarehouseById: $e', e, s);
      rethrow;
    }
  }

  Future<List<WarehouseModel>> insertSyncWarehouses(
      List<Map<String, dynamic>> warehouses) async {
    try {
      return await database.transaction((txn) async {
        List<WarehouseModel> insertedWarehouses = [];
        for (var warehouse in warehouses) {
          try {
            final existing = await txn.query(
              WarehouseTable.tableName,
              where: '${WarehouseTable.colIdServer} = ?',
              whereArgs: [warehouse['id_server']],
              limit: 1,
            );
            int id;
            if (existing.isNotEmpty) {
              await txn.update(
                WarehouseTable.tableName,
                warehouse,
                where: '${WarehouseTable.colIdServer} = ?',
                whereArgs: [warehouse['id_server']],
              );
              id = existing.first[WarehouseTable.colId] as int;
            } else {
              id = await txn.insert(WarehouseTable.tableName, warehouse);
            }
            final result = await txn.query(
              WarehouseTable.tableName,
              where: '${WarehouseTable.colId} = ?',
              whereArgs: [id],
              limit: 1,
            );
            if (result.isNotEmpty) {
              insertedWarehouses.add(WarehouseModel.fromDbLocal(result.first));
            }
          } catch (e, s) {
            _logger.warning('Error upserting warehouse: $e', e, s);
            rethrow;
          }
        }
        return insertedWarehouses;
      });
    } catch (e, s) {
      _logger.severe('Error insertSyncWarehouses: $e', e, s);
      rethrow;
    }
  }

  Future<WarehouseModel> insertWarehouse(Map<String, dynamic> warehouse) async {
    try {
      final id = await database.insert(WarehouseTable.tableName, warehouse);
      final result = await database.query(
        WarehouseTable.tableName,
        where: '${WarehouseTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      return WarehouseModel.fromDbLocal(result.first);
    } catch (e, s) {
      _logger.severe('Error insertWarehouse: $e', e, s);
      rethrow;
    }
  }

  Future<int> updateWarehouse(Map<String, dynamic> warehouse) async {
    try {
      return await database.update(
        WarehouseTable.tableName,
        warehouse,
        where: '${WarehouseTable.colId} = ?',
        whereArgs: [warehouse['id']],
      );
    } catch (e, s) {
      _logger.severe('Error updateWarehouse: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteWarehouse(int id) async {
    try {
      return await database.delete(
        WarehouseTable.tableName,
        where: '${WarehouseTable.colId} = ?',
        whereArgs: [id],
      );
    } catch (e, s) {
      _logger.severe('Error deleteWarehouse: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearWarehouses() async {
    try {
      return await database.delete(WarehouseTable.tableName);
    } catch (e, s) {
      _logger.severe('Error clearWarehouses: $e', e, s);
      rethrow;
    }
  }
}
