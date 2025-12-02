import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:transaction/data/datasources/transaction_local_data_source.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/models/transaction_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('concurrent inserts', () {
    late Database db;
    late TransactionLocalDataSource local;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);
      local = TransactionLocalDataSource(testDb: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('many parallel insertSyncTransaction calls succeed', () async {
      final tasks = List.generate(50, (_) async {
        final model = TransactionModel(
          warehouseId: 1,
          sequenceNumber: 1,
          orderTypeId: 1,
          date: DateTime.now(),
          totalAmount: 100,
          totalQty: 1,
        );
        final inserted = await local.insertSyncTransaction(model);
        return inserted?.id;
      });

      final results = await Future.wait(tasks);

      // check DB rows
      final rows = await db.query(TransactionTable.tableName);
      expect(rows.length, equals(50));
      expect(results.where((r) => r != null).length, equals(50));
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
