// lib/database/product_database.dart
import 'package:core/core.dart';
import 'package:landing_page_menu/data/datasources/landing_page_menu_database.dart';

class ProductTable {
  static const String _tbl = 'products';
  static final Logger _logger = Logger('ProductTable');

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tbl (
        id INTEGER PRIMARY KEY,
        id_server INTEGER NULL,
        name TEXT NULL,
        slug TEXT NULL,
        code TEXT NULL,
        type TEXT NULL,
        category_id INTEGER NULL,
        unit_id INTEGER NULL,
        business_id INTEGER NULL,
        cost REAL NULL,
        price REAL NULL,
        qty REAL NULL,
        alert_quantity REAL NULL,
        created_at TEXT NULL,
        updated_at TEXT NULL,
        synced_at TEXT NULL
      );
    ''');
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final db = await LandingPageMenuDatabase().database;
      return await db!.query(_tbl, orderBy: 'name');
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat mengambil produk: $e', e);
      return [];
    }
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final results =
          await db!.query(_tbl, where: 'id = ?', whereArgs: [id], limit: 1);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      _logger.severe(
          'Terjadi kesalahan saat mengambil produk berdasarkan ID: $e', e);
      return null;
    }
  }

  Future<bool> insertSync(List<Map<String, dynamic>> products) async {
    final db = await LandingPageMenuDatabase().database;
    int affected = 0;

    for (var product in products) {
      final idServer = product['id_server'];
      if (idServer == null) continue;

      final existing = await db!
          .query(_tbl, where: 'id_server = ?', whereArgs: [idServer], limit: 1);

      if (existing.isNotEmpty) {
        affected += await db.update(_tbl, product,
            where: 'id_server = ?', whereArgs: [idServer]);
      } else {
        affected += await db.insert(_tbl, product);
      }
    }
    return affected > 0;
  }

  Future<bool> insert(Map<String, dynamic> product) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final id = await db!.insert(_tbl, product);
      return id > 0;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat menambahkan produk: $e', e);
      return false;
    }
  }

  Future<bool> update(Map<String, dynamic> product) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final count = await db!
          .update(_tbl, product, where: 'id = ?', whereArgs: [product['id']]);
      return count > 0;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat memperbarui produk: $e', e);
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final count = await db!.delete(_tbl, where: 'id = ?', whereArgs: [id]);
      return count > 0;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat menghapus produk: $e', e);
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      final db = await LandingPageMenuDatabase().database;
      final count = await db!.delete(_tbl);
      return count > 0;
    } catch (e) {
      _logger.severe('Terjadi kesalahan saat menghapus semua produk: $e', e);
      return false;
    }
  }
}
