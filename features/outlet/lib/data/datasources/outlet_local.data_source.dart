import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import '../models/outlet.model.dart';
import 'db/outlet.dao.dart';

class OutletLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final _logger = Logger('OutletLocalDataSource');

  Future<List<OutletModel>> getOutlets() async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning("Database gagal dibuka/null");
        return [];
      }
      final query = OutletDao(db);

      final result = await query.getOutlets();

      return result;
    } catch (e, st) {
      _logger.severe('Error getOutlets', e, st);
      return [];
    }
  }

  Future<OutletModel?> insertDataOutlet(OutletModel insertOutlet) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning("Database gagal dibuka/null");
        return null;
      }
      final query = OutletDao(db);

      final insertedOutlet =
          await query.insertOutlet(insertOutlet.toInsertDbLocal());

      return insertedOutlet;
    } catch (e, st) {
      _logger.severe('Error insertDataOutlet', e, st);
      rethrow;
    }
  }

  Future<List<OutletModel>> insertSyncOutlets({
    required List<OutletModel>? outlets,
  }) async {
    if (outlets == null || outlets.isEmpty) return [];

    try {
      final now = DateTime.now();

      final dbEntities = outlets.map((e) {
        final modelWithSync = e.copyWith(syncedAt: now);
        return modelWithSync.toInsertDbLocal();
      }).toList();

      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning("Database gagal dibuka/null");
        return [];
      }
      final query = OutletDao(db);
      final result = await query.insertSyncOutlets(dbEntities);

      return result;
    } catch (e, st) {
      _logger.severe('Error insertSyncOutlets', e, st);
      return [];
    }
  }

  Future<int> deleteAllOutlets({
    required int id,
  }) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning("Database gagal dibuka/null");
        return 0;
      }
      final query = OutletDao(db);
      final result = await query.deleteOutlet(id);

      return result;
    } catch (e, st) {
      _logger.severe('Error deleteAllOutlets', e, st);
      rethrow;
    }
  }
}
