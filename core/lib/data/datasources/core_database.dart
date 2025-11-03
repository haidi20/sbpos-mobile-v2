import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:core/data/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CoreDatabaseHelper {
  static CoreDatabaseHelper? _databaseHelper;
  CoreDatabaseHelper._instance() {
    _databaseHelper = this;
  }

  factory CoreDatabaseHelper() =>
      _databaseHelper ?? CoreDatabaseHelper._instance();

  static Database? _database;

  static const String _tblUsers = 'user_auths';

  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDb();
    return _database;
  }

  Future<Database> _initDb() async {
    // await dotenv.load(); // Ensure dotenv is loaded
    final path = await getDatabasesPath();
    // print('version core: ${dotenv.env['VERSION']}');
    final databasePath = '$path/${dotenv.env['VERSION'] ?? ''}_db_auth.db';

    var db = await openDatabase(
      databasePath,
      version: 1,
      onCreate: _onCreate,
    );

    return db;
  }

  void _onCreate(Database db, int version) async {
    // Tabel master_tambats
    await db.execute('''
      CREATE TABLE $_tblUsers (
        id INTEGER PRIMARY KEY,
        username TEXT,
        token TEXT,
        email TEXT unique
      );
    ''');
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> results = await db!.query(
        _tblUsers,
        limit: 1,
      );

      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<int> countTableUser() async {
    final db = await database;
    final result =
        await db!.rawQuery('SELECT COUNT(*) as total FROM $_tblUsers');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> storeUser(UserModel user) async {
    final db = await database;
    // Menghapus semua data lama dari tabel
    await db!.delete(_tblUsers);

    print("core db nama petugas : ${user.namaPetugas}");

    return await db.insert(_tblUsers, user.toLocalDbJson());
  }

  Future<int> deleteUser() async {
    final db = await database;
    return await db!.delete(_tblUsers);
  }

  Future<void> deleteToken() async {
    final db = await database;
    final getUserMap = await getUser();
    UserModel getuser = UserModel();
    if (getUserMap != null) {
      getuser = UserModel.fromMap(getUserMap);
    }

    await db!.update(
      _tblUsers, // Nama tabel
      {'api_token': null}, // Set api_token menjadi NULL
      where: 'id = ?',
      whereArgs: [getuser.id], // Filter berdasarkan ID pengguna
    );
  }
}
