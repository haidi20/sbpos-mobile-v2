import 'package:core/data/datasources/core_database_schema_registry.dart';
import 'package:core/data/datasources/platforms/platform_db.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class CoreDatabaseMobile {
  static CoreDatabaseMobile? _databaseHelper;
  CoreDatabaseMobile._instance() {
    _databaseHelper = this;
  }

  factory CoreDatabaseMobile() =>
      _databaseHelper ?? CoreDatabaseMobile._instance();

  static Database? _database;

  static final Logger _logger = Logger('CoreDatabaseMobile');

  Future<Database?> get database async {
    try {
      if (_database != null) return _database;
      _database = await _initDb();
      return _database;
    } catch (e, stack) {
      _logger.severe('Failed to get database instance', e, stack);
      return null;
    }
  }

  Future<Database> _initDb() async {
    try {
      final path = await getDatabasesPath();
      final databasePath = '$path/app.db';
      final int versionDb = dotenv.env['VERSION_DB'] != null
          ? int.parse(dotenv.env['VERSION_DB']!)
          : 1;

      var db = await openDatabase(
        databasePath,
        version: versionDb,
        onCreate: _onCreate,
        onOpen: (Database db) async {
          try {
            await _ensureTables(db);
          } catch (e, stack) {
            _logger.warning('Failed to ensure tables on open', e, stack);
          }
        },
      );

      return db;
    } catch (e, stack) {
      _logger.severe('Failed to initialize database', e, stack);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      for (final query in CoreDatabaseSchemaRegistry.instance.createTableQueries) {
        await db.execute(query);
      }
      await _createAllIndexes(db);
    } catch (e, stack) {
      _logger.severe('Failed to create tables', e, stack);
      rethrow;
    }
  }

  Future<void> _ensureTables(Database db) async {
    for (final query in CoreDatabaseSchemaRegistry.instance.ensureTableQueries) {
      await db.execute(query);
    }
  }

  Future<void> _createAllIndexes(Database db) async {
    for (final query in CoreDatabaseSchemaRegistry.instance.createIndexQueries) {
      await db.execute(query);
    }
  }
}
