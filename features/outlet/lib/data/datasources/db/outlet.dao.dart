import 'outlet.table.dart';
import 'package:core/core.dart';
import '../../models/outlet.model.dart';

class OutletDao {
  final Database database;
  final _logger = Logger('OutletDao');

  OutletDao(this.database);

  Future<List<OutletModel>> getOutlets() async {
    try {
      final result = await database.query(OutletTable.tableName);
      return result.map((e) => OutletModel.fromDbLocal(e)).toList();
    } catch (e, s) {
      _logger.severe('Error getOutlets: $e', e, s);
      rethrow;
    }
  }

  Future<OutletModel?> getOutletById(int id) async {
    try {
      final results = await database.query(
        OutletTable.tableName,
        where: '\${OutletTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isNotEmpty) {
        return OutletModel.fromDbLocal(results.first);
      }
      return null;
    } catch (e, s) {
      _logger.severe('Error getOutletById: $e', e, s);
      rethrow;
    }
  }

  Future<List<OutletModel>> insertSyncOutlets(
      List<Map<String, dynamic>> outlets) async {
    try {
      return await database.transaction((txn) async {
        List<OutletModel> insertedOutlets = [];
        for (var outlet in outlets) {
          try {
            final existing = await txn.query(
              OutletTable.tableName,
              where: '\${OutletTable.colIdServer} = ?',
              whereArgs: [outlet['id_server']],
              limit: 1,
            );
            int id;
            if (existing.isNotEmpty) {
              await txn.update(
                OutletTable.tableName,
                outlet,
                where: '\${OutletTable.colIdServer} = ?',
                whereArgs: [outlet['id_server']],
              );
              id = existing.first[OutletTable.colId] as int;
            } else {
              id = await txn.insert(OutletTable.tableName, outlet);
            }
            final result = await txn.query(
              OutletTable.tableName,
              where: '\${OutletTable.colId} = ?',
              whereArgs: [id],
              limit: 1,
            );
            if (result.isNotEmpty) {
              insertedOutlets.add(OutletModel.fromDbLocal(result.first));
            }
          } catch (e, s) {
            _logger.warning('Error upserting outlet: $e', e, s);
            rethrow;
          }
        }
        return insertedOutlets;
      });
    } catch (e, s) {
      _logger.severe('Error insertSyncOutlets: $e', e, s);
      rethrow;
    }
  }

  Future<OutletModel> insertOutlet(Map<String, dynamic> outlet) async {
    try {
      final id = await database.insert(OutletTable.tableName, outlet);
      final result = await database.query(
        OutletTable.tableName,
        where: '\${OutletTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      return OutletModel.fromDbLocal(result.first);
    } catch (e, s) {
      _logger.severe('Error insertOutlet: $e', e, s);
      rethrow;
    }
  }

  Future<int> updateOutlet(Map<String, dynamic> outlet) async {
    try {
      return await database.update(
        OutletTable.tableName,
        outlet,
        where: '\${OutletTable.colId} = ?',
        whereArgs: [outlet['id']],
      );
    } catch (e, s) {
      _logger.severe('Error updateOutlet: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteOutlet(int id) async {
    try {
      return await database.delete(
        OutletTable.tableName,
        where: '\${OutletTable.colId} = ?',
        whereArgs: [id],
      );
    } catch (e, s) {
      _logger.severe('Error deleteOutlet: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearOutlets() async {
    try {
      return await database.delete(OutletTable.tableName);
    } catch (e, s) {
      _logger.severe('Error clearOutlets: $e', e, s);
      rethrow;
    }
  }
}
