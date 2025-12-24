import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// sqlite_api is re-exported by sqflite_common_ffi; no separate import needed

Future<Database> createTestDatabase() async {
  sqfliteFfiInit();
  // Set global factory for sqflite
  databaseFactory = databaseFactoryFfi;

  // Gunakan database in-memory untuk isolasi
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  return db;
}
