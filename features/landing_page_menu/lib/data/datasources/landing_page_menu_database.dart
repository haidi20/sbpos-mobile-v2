// lib/database/landing_page_menu_database.dart
import 'package:core/core.dart';
import 'package:landing_page_menu/data/datasources/tables/product_table.dart';
import 'package:landing_page_menu/data/datasources/tables/category_table.dart';
import 'package:landing_page_menu/data/datasources/tables/category_parent_table.dart';

class LandingPageMenuDatabase {
  static LandingPageMenuDatabase? _databaseHelper;
  LandingPageMenuDatabase._instance() {
    _databaseHelper = this;
  }

  factory LandingPageMenuDatabase() =>
      _databaseHelper ?? LandingPageMenuDatabase._instance();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDb();
    return _database;
  }

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    final databasePath =
        '$path/${dotenv.env['VERSION'] ?? ''}_landing_page_menu.db';
    final int versionDb = dotenv.env['VERSION_DB'] != null
        ? int.parse(dotenv.env['VERSION_DB']!)
        : 1;

    return await openDatabase(
      databasePath,
      version: versionDb,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await ProductTable.createTable(db);
    await CategoryTable.createTable(db);
    await CategoryParentTable.createTable(db);
  }
}
