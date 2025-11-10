// lib/database/category_parent_database.dart
import 'package:core/core.dart';
import 'package:landing_page_menu/data/datasources/landing_page_menu_database.dart';

class CategoryParentTable {
  static const String _tbl = 'category_parents';
  static final Logger _logger = Logger('CategoryParentTable');

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tbl (
        id INTEGER PRIMARY KEY,
        id_server INTEGER NULL,
        name TEXT NULL,
        deleted_at TEXT NULL,
        created_at TEXT NULL,
        updated_at TEXT NULL,
        synced_at TEXT NULL
      );
    ''');
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final db = await LandingPageMenuDatabase().database;
      return await db!.query(_tbl, where: 'deleted_at IS NULL');
    } catch (e) {
      _logger.severe(
          'Terjadi kesalahan saat mengambil data kategori induk: $e', e);
      return [];
    }
  }

  Future<Map<String, dynamic>?> findById(int id) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final results = await db!.query(_tbl,
          where: 'id = ? AND deleted_at IS NULL', whereArgs: [id], limit: 1);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat mengambil kategori induk: $e', e);
      return null;
    }
  }

  Future<bool> insertSync(List<Map<String, dynamic>> products) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      int affected = 0;

      for (var product in products) {
        final idServer = product['id_server'];
        if (idServer == null) continue;

        final existing = await db!.query(
          _tbl,
          where: 'id_server = ?',
          whereArgs: [idServer],
          limit: 1,
        );

        if (existing.isNotEmpty) {
          affected += await db.update(
            _tbl,
            product,
            where: 'id_server = ?',
            whereArgs: [idServer],
          );
        } else {
          affected += await db.insert(_tbl, product);
        }
      }
      return affected > 0;
    } catch (e) {
      _logger.severe(
          'Terjadi kesalahan saat sinkronisasi kategori induk: $e', e);
      return false;
    }
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final id = await db!.insert(_tbl, data);
      return id > 0;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat menambah kategori induk: $e', e);
      return false;
    }
  }

  Future<bool> update(Map<String, dynamic> data) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final count = await db!
          .update(_tbl, data, where: 'id = ?', whereArgs: [data['id']]);
      return count > 0;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat mengubah kategori induk: $e', e);
      return false;
    }
  }

  Future<bool> deleteSoft(int id) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final now = DateTime.now().toIso8601String();
      final count = await db!
          .update(_tbl, {'deleted_at': now}, where: 'id = ?', whereArgs: [id]);
      return count > 0;
    } catch (e) {
      _logger.severe(
          'Terjadi kesalahan saat menghapus kategori induk (soft delete): $e',
          e);
      return false;
    }
  }
}
