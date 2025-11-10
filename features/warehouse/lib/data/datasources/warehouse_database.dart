import 'package:core/core.dart';

class WarehouseDatabase {
  static WarehouseDatabase? _databaseHelper;
  WarehouseDatabase._instance() {
    _databaseHelper = this;
  }

  factory WarehouseDatabase() =>
      _databaseHelper ?? WarehouseDatabase._instance();

  static Database? _database;

  static const String _tblWarehouses = 'warehouses';

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDb();
    return _database;
  }

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    final databasePath = '$path/${dotenv.env['VERSION'] ?? ''}_warehouse.db';
    final int versionDb = dotenv.env['VERSION_DB'] != null
        ? int.parse(dotenv.env['VERSION_DB']!)
        : 1;

    var db = await openDatabase(
      databasePath,
      version: versionDb,
      onCreate: _onCreate,
    );

    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tblWarehouses (
        id INTEGER PRIMARY KEY,
        id_server INTEGER,
        name TEXT,
        address TEXT NULL,
        created_at TEXT NULL,
        updated_at TEXT NULL,
        synced_at TEXT NULL
      );
    ''');
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    try {
      final db = await database;
      return await db!.query(_tblWarehouses);
    } catch (e) {
      print("Error fetching warehouses: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getWarehouseById(int id) async {
    try {
      final db = await database;
      final results = await db!.query(
        _tblWarehouses,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print("Error fetching warehouse: $e");
      return null;
    }
  }

  Future<int> insertSyncWarehouses(
    List<Map<String, dynamic>> warehouses,
  ) async {
    final db = await database;
    int result = 0;
    for (var warehouse in warehouses) {
      final existing = await db!.query(
        _tblWarehouses,
        where: 'id_server = ?',
        whereArgs: [warehouse['id_server']],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        result += await db.update(
          _tblWarehouses,
          warehouse,
          where: 'id_server = ?',
          whereArgs: [warehouse['id_server']],
        );
      } else {
        result += await db.insert(_tblWarehouses, warehouse);
      }
    }
    return result;
  }

  Future<int> insertWarehouse(Map<String, dynamic> warehouse) async {
    final db = await database;
    return await db!.insert(_tblWarehouses, warehouse);
  }

  Future<int> updateWarehouse(Map<String, dynamic> warehouse) async {
    final db = await database;
    return await db!.update(
      _tblWarehouses,
      warehouse,
      where: 'id = ?',
      whereArgs: [warehouse['id']],
    );
  }

  Future<int> deleteWarehouse(int id) async {
    final db = await database;
    return await db!.delete(
      _tblWarehouses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearWarehouses() async {
    final db = await database;
    return await db!.delete(_tblWarehouses);
  }
}
