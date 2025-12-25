import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/data/datasources/local_database_sembast.dart'
    as sembast_db;
import 'package:product/data/datasources/db/product.table.dart'
    as product_table;
import 'package:product/data/datasources/db/packet.table.dart' as packet_table;

void main() {
  test('clear local sembast product & packet tables', () async {
    // Only run for web/sembast path to avoid touching native sqlite.
    // This test will initialize the sembast DB used by tests and clear tables.
    if (!kIsWeb) return;
    await sembast_db.LocalDatabase.instance.init('app_local.db');
    await sembast_db.LocalDatabase.instance
        .deleteAll(product_table.ProductTable.tableName);
    await sembast_db.LocalDatabase.instance
        .deleteAll(packet_table.PacketTable.tableName);
    await sembast_db.LocalDatabase.instance.deleteAll('packet_items');
    final p = await sembast_db.LocalDatabase.instance
        .getAll(product_table.ProductTable.tableName);
    final pk = await sembast_db.LocalDatabase.instance
        .getAll(packet_table.PacketTable.tableName);
    expect(p.length, equals(0));
    expect(pk.length, equals(0));
    await sembast_db.LocalDatabase.instance.close();
  });
}
