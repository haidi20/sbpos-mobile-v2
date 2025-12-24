import 'package:sqflite/sqflite.dart';

/// Thin native LocalDatabase implementation using `sqflite`.
class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  Database? _db;

  Future<void> init([String path = 'app_native.db']) async {
    if (_db != null) return;
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      // no-op default; callers should manage tables
    });
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    if (_db == null) await init();
    return await _db!
        .insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Delete records where [field] equals [value], return number of deleted rows.
  Future<int> deleteWhereEquals(
      String table, String field, dynamic value) async {
    if (_db == null) await init();
    return await _db!.delete(table, where: '$field = ?', whereArgs: [value]);
  }

  /// Get a single record by integer key (assumes primary key column is 'id').
  Future<Map<String, dynamic>?> getByKey(String table, int key) async {
    if (_db == null) await init();
    final rows =
        await _db!.query(table, where: 'id = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// Put (insert or update) a record with a specific integer key.
  Future<void> put(String table, int key, Map<String, dynamic> value) async {
    if (_db == null) await init();
    // Try update first
    final updated =
        await _db!.update(table, value, where: 'id = ?', whereArgs: [key]);
    if (updated == 0) {
      // insert with explicit id if update affected no rows
      final toInsert = Map<String, dynamic>.from(value);
      toInsert['id'] = key;
      await _db!.insert(table, toInsert,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    if (_db == null) await init();
    return await _db!.query(table);
  }

  Future<int> deleteAll(String table) async {
    if (_db == null) await init();
    return await _db!.delete(table);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
