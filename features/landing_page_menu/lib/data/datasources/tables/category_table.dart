// lib/database/category_database.dart
import 'package:core/core.dart';
import 'package:landing_page_menu/data/datasources/landing_page_menu_database.dart';

class CategoryTable {
  static const String _tbl = 'categories';
  static final Logger _logger = Logger('CategoryTable');

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tbl (
        id INTEGER PRIMARY KEY,
        name TEXT NULL,
        category_parents_id INTEGER NULL,
        business_id INTEGER NULL,
        is_active INTEGER NULL,
        deleted_at TEXT NULL,
        created_at TEXT NULL,
        updated_at TEXT NULL,
        synced_at TEXT NULL
      );
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllActive() async {
    try {
      final db = await LandingPageMenuDatabase().database;
      return await db!
          .query(_tbl, where: 'deleted_at IS NULL AND is_active = 1');
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat mengambil kategori aktif: $e', e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final db = await LandingPageMenuDatabase().database;
      return await db!.query(_tbl, where: 'deleted_at IS NULL');
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat mengambil semua kategori: $e', e);
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
      _logger.severe(
          'Terjadi kesalahan saat mengambil kategori berdasarkan ID: $e', e);
      return null;
    }
  }

  Future<bool> insertSync(List<Map<String, dynamic>> categories) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      int affected = 0;

      for (var category in categories) {
        final idServer = category['id_server'];
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
            category,
            where: 'id_server = ?',
            whereArgs: [idServer],
          );
        } else {
          affected += await db.insert(_tbl, category);
        }
      }
      return affected > 0;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat sinkronisasi kategori: $e', e);
      return false;
    }
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final id = await db!.insert(_tbl, data);
      return id > 0;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat menambah kategori: $e', e);
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
      _logger.severe('Terjadi kesalahan saat mengubah kategori: $e', e);
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
          'Terjadi kesalahan saat menghapus kategori (soft delete): $e', e);
      return false;
    }
  }
}
