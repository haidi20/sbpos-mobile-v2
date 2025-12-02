import 'package:core/core.dart';
import 'package:core/data/datasources/db/auth_user.table.dart';
import 'package:warehouse/data/datasources/db/warehouse.table.dart';
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
      await db.execute(WarehouseTable.createTableQuery);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);
    } catch (e, stack) {
      _logger.severe('Failed to create tables', e, stack);
      rethrow;
    }
  }
}
