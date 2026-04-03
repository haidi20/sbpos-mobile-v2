import 'package:core/data/datasources/core_database_schema_registry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CoreDatabaseDesktop {
  static CoreDatabaseDesktop? _databaseHelper;
  CoreDatabaseDesktop._instance() {
    _databaseHelper = this;
  }

  factory CoreDatabaseDesktop() =>
      _databaseHelper ?? CoreDatabaseDesktop._instance();

  static Database? _database;

  static final Logger _logger = Logger('CoreDatabaseDesktop');

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
      // Initialize ffi
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;

      final path = await databaseFactory.getDatabasesPath();
      final databasePath = '$path/app.db';
      final int versionDb = dotenv.env['VERSION_DB'] != null
          ? int.parse(dotenv.env['VERSION_DB']!)
          : 1;

      var db = await databaseFactory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: versionDb,
          onCreate: _onCreate,
          onOpen: (Database db) async {
            try {
              await _ensureTables(db);
            } catch (e, stack) {
              _logger.warning('Failed to ensure tables on open', e, stack);
            }
          },
        ),
      );

      return db;
    } catch (e, stack) {
      _logger.severe('Failed to initialize desktop database', e, stack);
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
