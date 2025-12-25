import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/data/datasources/db/product.dao.dart';
import 'package:product/data/models/product.model.dart';
import 'package:product/data/datasources/db/product.table.dart'
    as product_table;
import 'package:core/data/datasources/local_database_sembast.dart'
    as sembast_db;

// Native imports
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.io) 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('product CRUD uses real local DB', () async {
    if (kIsWeb) {
      // Web / sembast path
      await sembast_db.LocalDatabase.instance.init('test_product_crud.db');
      await sembast_db.LocalDatabase.instance
          .deleteAll(product_table.ProductTable.tableName);

      final dao = ProductDao(null);
      // Create
      final p = ProductModel(name: 'Test Product', price: 12345.0);
      final inserted = await dao.insertProduct(p.toInsertDbLocal());
      expect(inserted.id, isNotNull);

      // Read
      final list = await dao.getProducts();
      expect(list.length, greaterThanOrEqualTo(1));

      final fetched = await dao.getProductById(inserted.id!);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Test Product'));

      // Update (sembast: put by key)
      final updatedMap = inserted.toInsertDbLocal()
        ..['name'] = 'Updated Product'
        ..['price'] = 20000;
      await sembast_db.LocalDatabase.instance
          .put(product_table.ProductTable.tableName, inserted.id!, updatedMap);
      final updated = await dao.getProductById(inserted.id!);
      expect(updated!.name, equals('Updated Product'));
      expect(updated.price, equals(20000));

      // Delete
      final del = await dao.deleteProduct(inserted.id!);
      expect(del, greaterThanOrEqualTo(0));

      await sembast_db.LocalDatabase.instance
          .deleteAll(product_table.ProductTable.tableName);
      await sembast_db.LocalDatabase.instance.close();
    } else {
      // Native path (sqlite ffi in-memory)
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create table
      await db.execute(product_table.ProductTable.createTableQuery);
      await db.execute(product_table.ProductTable.createIndexName);

      final dao = ProductDao(db);

      // Create
      final p = ProductModel(name: 'Test Product', price: 12345.0);
      final inserted = await dao.insertProduct(p.toInsertDbLocal());
      expect(inserted.id, isNotNull);

      // Read
      final list = await dao.getProducts();
      expect(list.length, greaterThanOrEqualTo(1));

      final fetched = await dao.getProductById(inserted.id!);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Test Product'));

      // Update using raw update
      await db.update(product_table.ProductTable.tableName,
          {'name': 'Updated Product', 'price': 20000},
          where: '${product_table.ProductTable.colId} = ?',
          whereArgs: [inserted.id]);
      final updated = await dao.getProductById(inserted.id!);
      expect(updated!.name, equals('Updated Product'));
      expect(updated.price, equals(20000));

      // Delete
      final del = await dao.deleteProduct(inserted.id!);
      expect(del, greaterThanOrEqualTo(0));

      await db.close();
    }
  });
}
