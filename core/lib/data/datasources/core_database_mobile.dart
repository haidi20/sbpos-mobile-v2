import 'package:core/core.dart';
import 'package:outlet/data/datasources/db/outlet.table.dart';
import 'package:core/data/datasources/db/auth_user.table.dart';
import 'package:product/data/datasources/db/packet.table.dart';
import 'package:product/data/datasources/db/product.table.dart';
import 'package:customer/data/datasources/db/customer.table.dart';
import 'package:product/data/datasources/db/packet_item.table.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';

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
      await db.execute(OutletTable.createTableQuery);
      await db.execute(PacketTable.createTableQuery);
      await db.execute(ProductTable.createTableQuery);
      await db.execute(PacketItemTable.createTableQuery);
      await db.execute(CustomerTable.createTableQuery);
      await db.execute(AuthUserTable.createTableQuery);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);

      await _createAllIndexes(db);
    } catch (e, stack) {
      _logger.severe('Failed to create tables', e, stack);
      rethrow;
    }
  }

  Future<void> _ensureTables(Database db) async {
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

  Future<void> _createAllIndexes(Database db) async {
    await db.execute(TransactionDetailTable.createUniqueIndexProduct);
    await db.execute(TransactionDetailTable.createUniqueIndexPacket);
    await db.execute(TransactionDetailTable.createIndexProductId);
    await db.execute(TransactionDetailTable.createIndexProductName);

    await db.execute(TransactionTable.createIndexSequenceNumber);
    await db.execute(TransactionTable.createIndexNumberTable);
    await db.execute(TransactionTable.createIndexDate);

    await db.execute(CustomerTable.createIndexName);
    await db.execute(ProductTable.createIndexName);
    await db.execute(AuthUserTable.createIndexUsername);
  }
}
