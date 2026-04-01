import 'package:core/core.dart';
import 'package:core/data/datasources/local_database_sembast.dart'
    as sembast_db;
import 'package:setting/data/datasources/db/setting.table.dart';
import 'package:setting/data/models/setting_config.model.dart';

class SettingDao {
  SettingDao(this.database);

  final Database? database;
  final _logger = Logger('SettingDao');
  final bool isShowLog = false;

  void _logInfo(String message) {
    if (isShowLog) _logger.info(message);
  }

  void _logSevere(String message, [Object? error, StackTrace? stackTrace]) {
    if (isShowLog) _logger.severe(message, error, stackTrace);
  }

  Future<SettingConfigModel?> getSettingConfig() async {
    try {
      if (database != null) {
        final rows = await database!.query(
          SettingTable.tableName,
          where: '${SettingTable.colId} = ?',
          whereArgs: [1],
          limit: 1,
        );
        if (rows.isEmpty) {
          return null;
        }
        return SettingConfigModel.fromDbLocal(rows.first);
      }

      final map = await sembast_db.LocalDatabase.instance
          .getByKey(SettingTable.tableName, 1);
      if (map == null) {
        return null;
      }
      return SettingConfigModel.fromDbLocal(map);
    } catch (e, st) {
      _logSevere('Error getSettingConfig: $e', e, st);
      rethrow;
    }
  }

  Future<SettingConfigModel> upsertSettingConfig(
    Map<String, dynamic> config,
  ) async {
    try {
      final cleaned = Map<String, dynamic>.from(config)
        ..removeWhere((key, value) => value == null);

      if (database != null) {
        return await database!.transaction((txn) async {
          final existing = await txn.query(
            SettingTable.tableName,
            where: '${SettingTable.colId} = ?',
            whereArgs: [1],
            limit: 1,
          );

          if (existing.isEmpty) {
            await txn.insert(
              SettingTable.tableName,
              cleaned,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else {
            final updateMap = Map<String, dynamic>.from(cleaned)
              ..remove(SettingTable.colId);
            await txn.update(
              SettingTable.tableName,
              updateMap,
              where: '${SettingTable.colId} = ?',
              whereArgs: [1],
            );
          }

          final rows = await txn.query(
            SettingTable.tableName,
            where: '${SettingTable.colId} = ?',
            whereArgs: [1],
            limit: 1,
          );
          final model = SettingConfigModel.fromDbLocal(rows.first);
          _logInfo('upsertSettingConfig: success');
          return model;
        });
      }

      final updateMap = Map<String, dynamic>.from(cleaned)..remove('id');
      await sembast_db.LocalDatabase.instance
          .put(SettingTable.tableName, 1, updateMap);
      final map = await sembast_db.LocalDatabase.instance
          .getByKey(SettingTable.tableName, 1);
      final model = SettingConfigModel.fromDbLocal(map!);
      _logInfo('upsertSettingConfig (web): success');
      return model;
    } catch (e, st) {
      _logSevere('Error upsertSettingConfig: $e', e, st);
      rethrow;
    }
  }

  Future<int> clearSettings() async {
    try {
      if (database != null) {
        return await database!.delete(SettingTable.tableName);
      }
      return await sembast_db.LocalDatabase.instance
          .deleteByKey(SettingTable.tableName, 1);
    } catch (e, st) {
      _logSevere('Error clearSettings: $e', e, st);
      rethrow;
    }
  }
}
