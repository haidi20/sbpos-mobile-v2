import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// sqlite_api re-exported

import 'package:transaction/data/datasources/db/transaction.table.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Transaction table has required columns', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    try {
      await db.execute(TransactionTable.createTableQuery);

      // Query pragma to get table info
      final info = await db
          .rawQuery("PRAGMA table_info('${TransactionTable.tableName}')");
      final columns = info.map((r) => r['name']?.toString()).toList();

      expect(
          columns,
          containsAll([
            TransactionTable.colId,
            TransactionTable.colIdServer,
            TransactionTable.colSyncedAt,
            TransactionTable.colTotalAmount,
            TransactionTable.colTotalQty,
          ]));
    } finally {
      await db.close();
    }
  });
}
