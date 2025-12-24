import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/data/datasources/db/product.dao.dart';
import 'package:product/data/models/product.model.dart';
import 'package:product/data/datasources/db/product.table.dart';

// Native imports (use stub fallback for analysis)
import 'sqflite_stub.dart'
    if (dart.library.io) 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Web (sembast) import
import 'package:core/data/datasources/local_database_sembast.dart'
    as sembast_db;

void main() {
  test('product seeder: insert product into local DB (platform aware)',
      () async {
    if (kIsWeb) {
      // Web path: use sembast LocalDatabase
      await sembast_db.LocalDatabase.instance.init('test_product.db');
      // clear store
      await sembast_db.LocalDatabase.instance.deleteAll(ProductTable.tableName);

      final dao = ProductDao(null);
      const p = ProductModel(name: 'Seeder Product', price: 123.45);
      final id = await dao.insertProduct(p.toInsertDbLocal());
      expect(id, isNotNull);

      final items = await sembast_db.LocalDatabase.instance
          .getAll(ProductTable.tableName);
      expect(items.length, greaterThanOrEqualTo(1));
      await sembast_db.LocalDatabase.instance.deleteAll(ProductTable.tableName);
      await sembast_db.LocalDatabase.instance.close();
    } else {
      // Native path (mobile/desktop): use sqflite ffi in-memory
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      // create table
      await db.execute(ProductTable.createTableQuery);
      await db.execute(ProductTable.createIndexName);

      final dao = ProductDao(db);
      const p = ProductModel(name: 'Seeder Product', price: 123.45);
      final id = await dao.insertProduct(p.toInsertDbLocal());
      expect(id, isNot(0));

      final rows = await db.query(ProductTable.tableName);
      expect(rows.length, greaterThanOrEqualTo(1));
      await db.close();
    }
  });
}
