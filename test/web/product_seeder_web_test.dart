import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/data/datasources/db/product.dao.dart';
import 'package:product/data/models/product.model.dart';
import 'package:product/data/datasources/db/product.table.dart';
import 'package:core/data/datasources/local_database_sembast.dart'
    as sembast_db;

void main() {
  test('web product seeder: insert product into sembast web DB', () async {
    if (!kIsWeb) return;
    await sembast_db.LocalDatabase.instance.init('web_test_product.db');
    await sembast_db.LocalDatabase.instance.deleteAll(ProductTable.tableName);

    final dao = ProductDao(null);
    final p = ProductModel(name: 'Web Seeder Product', price: 9.99);
    final id = await dao.insertProduct(p.toInsertDbLocal());
    expect(id, isNotNull);

    final items =
        await sembast_db.LocalDatabase.instance.getAll(ProductTable.tableName);
    expect(items.length, greaterThanOrEqualTo(1));

    await sembast_db.LocalDatabase.instance.deleteAll(ProductTable.tableName);
    await sembast_db.LocalDatabase.instance.close();
  });
}
