import 'package:core/core.dart';
import 'package:core/data/models/user_model.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

class CoreDatabase {
  static CoreDatabase? _databaseHelper;
  CoreDatabase._instance() {
    _databaseHelper = this;
  }

  factory CoreDatabase() => _databaseHelper ?? CoreDatabase._instance();

  static Database? _database;

  static const String _tblUsers = 'user_auths';

  static final Logger _logger = Logger('CoreDatabase');

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
    final databasePath = '$path/${dotenv.env['VERSION'] ?? ''}_auth.db';
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
    // Tabel master_tambats
    await db.execute('''
      CREATE TABLE $_tblUsers (
        id INTEGER PRIMARY KEY,
        username TEXT,
        password TEXT,
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
      _logger.severe("Error fetching user: $e");
      return null;
    }
  }

  Future<bool> authUser({
    required String email,
    required String password,
  }) async {
    try {
      final db = await database;

      // 1. Cari user berdasarkan email saja
      final List<Map<String, dynamic>> results = await db!.query(
        _tblUsers,
        where: 'email = ?',
        whereArgs: [email],
      );

      // _logger.info("Query results: $results");

      if (results.isEmpty) return false;

      final storedHash = results.first['password'] as String?;

      // _logger.info("Stored hash: $storedHash");
      // _logger.info("Input password: $password");

      if (storedHash == null) return false;

      // 2. Verifikasi password dengan bcrypt
      final isValid = await FlutterBcrypt.verify(
        password: password,
        hash: storedHash,
      );
      return isValid;
    } catch (e) {
      _logger.severe("Error authenticating user: $e");
      return false;
    }
  }

  Future<int> countUser() async {
    final db = await database;
    final result =
        await db!.rawQuery('SELECT COUNT(*) as total FROM $_tblUsers');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> storeUser(UserModel user) async {
    final db = await database;
    await db!.delete(_tblUsers);

    // 👇 Tunggu hasil toLocalDbJson() sebelum insert
    final userMap = await user.toLocalDbJson(); // <-- await di sini
    return await db.insert(_tblUsers, userMap);
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
      {'token': null}, // Set api_token menjadi NULL
      where: 'id = ?',
      whereArgs: [getuser.id], // Filter berdasarkan ID pengguna
    );
  }
}
