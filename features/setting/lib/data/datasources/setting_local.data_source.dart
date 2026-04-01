import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:setting/data/datasources/db/setting.dao.dart';
import 'package:setting/data/models/setting_config.model.dart';
import 'package:setting/data/seeders/setting_local.seeder.dart';

class SettingLocalDataSource with BaseErrorHelper {
  SettingLocalDataSource({
    Database? testDb,
    SettingLocalSeeder? seeder,
  })  : _testDb = testDb,
        _seeder = seeder ?? const SettingLocalSeeder();

  final CoreDatabase databaseHelper = CoreDatabase();
  final Database? _testDb;
  final SettingLocalSeeder _seeder;
  final _logger = Logger('SettingLocalDataSource');
  final bool isShowLog = false;

  void _logWarning(String message) {
    if (isShowLog) _logger.warning(message);
  }

  void _logSevere(String message, [Object? error, StackTrace? stackTrace]) {
    if (isShowLog) _logger.severe(message, error, stackTrace);
  }

  @visibleForTesting
  SettingDao createDao(Database? db) => SettingDao(db);

  Future<SettingConfigModel> getSettingConfig() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      final result = await dao.getSettingConfig();
      if (result != null) {
        return result;
      }

      final seeded = await dao.upsertSettingConfig(
        _seeder.buildInitialConfig().toDbLocal(),
      );
      return seeded;
    } catch (e, st) {
      _logSevere('Error getSettingConfig local', e, st);
      rethrow;
    }
  }

  Future<SettingConfigModel> saveSettingConfig(SettingConfigModel config) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null, using web local store for settings');
      }
      final dao = createDao(db);
      return await dao.upsertSettingConfig(config.toDbLocal());
    } catch (e, st) {
      _logSevere('Error saveSettingConfig local', e, st);
      rethrow;
    }
  }

  Future<int> clearSettings() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      return await dao.clearSettings();
    } catch (e, st) {
      _logSevere('Error clearSettings local', e, st);
      rethrow;
    }
  }
}
