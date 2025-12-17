import 'package:core/core.dart';
import 'package:outlet/data/datasources/db/outlet.table.dart';
import 'package:core/data/datasources/db/auth_user.table.dart';
import 'package:customer/data/datasources/db/customer.table.dart';
import 'package:product/data/datasources/db/product.table.dart';
import 'package:product/data/datasources/db/packet.table.dart';
import 'package:product/data/datasources/db/packet_item.table.dart';
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

          // Ensure required columns exist for known tables. This is a safe,
          // best-effort fix for older DB files that were created before
          // new columns (e.g. `is_paid`) were added to the schema. We try to
          // add missing columns with ALTER TABLE so existing data is preserved.
          try {
            await _ensureColumns(db);
          } catch (e, stack) {
            _logger.warning('Failed to ensure table columns on open', e, stack);
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
      await db.execute(OutletTable.createTableQuery);
      await db.execute(PacketTable.createTableQuery);
      await db.execute(ProductTable.createTableQuery);
      await db.execute(PacketItemTable.createTableQuery);
      await db.execute(CustomerTable.createTableQuery);
      await db.execute(AuthUserTable.createTableQuery);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);
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
      PacketTable.createTableQuery,
      PacketItemTable.createTableQuery,
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

  /// Ensure specific columns exist on tables. This is defensive and idempotent:
  /// it checks `PRAGMA table_info(...)` and adds columns if they're missing.
  Future<void> _ensureColumns(Database db) async {
    try {
      // Helper to check if a column exists in a table
      Future<bool> columnExists(String table, String column) async {
        final rows = await db.rawQuery('PRAGMA table_info($table)');
        for (final r in rows) {
          final name = r['name']?.toString();
          if (name == column) return true;
        }
        return false;
      }

      // transactions.is_paid
      const txTable = TransactionTable.tableName;
      const isPaidCol = TransactionTable.colIsPaid;
      final hasIsPaid = await columnExists(txTable, isPaidCol);
      if (!hasIsPaid) {
        _logger.info('Adding missing column `$isPaidCol` to table `$txTable`');
        await db.execute(
            'ALTER TABLE $txTable ADD COLUMN $isPaidCol INTEGER NOT NULL DEFAULT 0');
      }

      // products.image
      const prodTable = ProductTable.tableName;
      const imageCol = ProductTable.colImage;
      final hasImage = await columnExists(prodTable, imageCol);
      if (!hasImage) {
        _logger.info('Adding missing column `$imageCol` to table `$prodTable`');
        await db.execute('ALTER TABLE $prodTable ADD COLUMN $imageCol TEXT');
      }
    } catch (e, stack) {
      _logger.warning('Error ensuring columns', e, stack);
    }
  }
}
