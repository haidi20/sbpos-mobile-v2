import 'package:core/core.dart';
import 'package:outlet/data/datasources/db/outlet.table.dart';
import 'package:core/data/datasources/db/auth_user.table.dart';
import 'package:customer/data/datasources/db/customer.table.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';

class CoreDatabase {
  static CoreDatabase? _databaseHelper;
  CoreDatabase._instance() {
    _databaseHelper = this;
  }

  factory CoreDatabase() => _databaseHelper ?? CoreDatabase._instance();

  static Database? _database;

  static final Logger _logger = Logger('CoreDatabase');

  Future<Database?> get database async {
    try {
      if (_database != null) return _database;
      // lazily instantiate the db the first time it is accessed
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
        onUpgrade: _onUpgrade,
        onOpen: (Database db) async {
          // Ensure tables exist on open (helps when DB file exists but some tables are missing)
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

  void _onCreate(Database db, int version) async {
    try {
      await db.execute(AuthUserTable.createTableQuery);
      await db.execute(OutletTable.createTableQuery);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);
      await db.execute(CustomerTable.createTableQuery);
    } catch (e, stack) {
      _logger.severe('Failed to create tables', e, stack);
      rethrow;
    }
  }

  Future<void> _ensureTables(Database db) async {
    // Execute CREATE TABLE IF NOT EXISTS for all known tables to avoid 'no such table' errors
    final queries = [
      AuthUserTable.createTableQuery,
      OutletTable.createTableQuery,
      TransactionTable.createTableQuery,
      TransactionDetailTable.createTableQuery,
      CustomerTable.createTableQuery,
    ];

    for (var q in queries) {
      final safeQ = q.replaceFirst(
          RegExp(r'CREATE TABLE', caseSensitive: false),
          'CREATE TABLE IF NOT EXISTS');
      await db.execute(safeQ);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.info('Upgrading database from v$oldVersion to v$newVersion');
    // Apply incremental migrations for each version step
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      try {
        switch (v) {
          case 2:
            // Example migration v1 -> v2:
            // - add `last_login` column to `auth_users`
            // Note: ALTER TABLE ADD COLUMN is safe in SQLite (adds NULLable column)
            await db.execute(
                'ALTER TABLE ${AuthUserTable.tableName} ADD COLUMN last_login INTEGER');
            _logger.info('Migration to v2 applied: add last_login column');
            break;

          case 3:
            // Example migration v2 -> v3:
            // - create a settings table
            await db.execute(
                'CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT)');
            _logger.info('Migration to v3 applied: create settings table');
            break;

          // Add more cases here for future versions

          default:
            _logger.info('No migration defined for v$v');
        }
      } catch (e, stack) {
        // Log and continue: avoid failing entire upgrade on single migration
        _logger.warning('Migration to v$v failed', e, stack);
      }
    }
  }
}
