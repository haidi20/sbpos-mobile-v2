import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:transaction/data/datasources/transaction_local_data_source.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/models/transaction_model.dart';

/// Flaky DAO that fails first N calls then delegates to real DAO.
class FlakyDao extends TransactionDao {
  int failTimes;

  FlakyDao(super.db, {this.failTimes = 2});

  @override
  Future<TransactionModel> insertSyncTransaction(
      Map<String, dynamic> tx, List<Map<String, dynamic>> details) async {
    if (failTimes > 0) {
      failTimes -= 1;
      throw Exception('Simulated disk full');
    }
    return await super.insertSyncTransaction(tx, details);
  }
}

class FlakyLocal extends TransactionLocalDataSource {
  final int failCount;
  FlakyLocal({required Database testDb, this.failCount = 2})
      : super(testDb: testDb) {
    _flakyCount = failCount;
  }

  late int _flakyCount;

  @override
  TransactionDao createDao(Database db) {
    return FlakyDao(db, failTimes: _flakyCount);
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('failure and retry', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertSyncTransaction retries on transient failures', () async {
      final flaky = FlakyLocal(testDb: db, failCount: 2);

      final model = TransactionModel(
        warehouseId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 100,
        totalQty: 1,
      );

      // Should succeed because TransactionLocalDataSource has retry logic
      final inserted = await flaky.insertSyncTransaction(model);
      expect(inserted, isNotNull);
      expect(inserted!.id, isNotNull);

      final rows = await db.query(TransactionTable.tableName);
      expect(rows.length, equals(1));
    });

    test('insertSyncTransaction ultimately fails if retries exhausted',
        () async {
      // Create flaky that will always fail (failCount > retry attempts in source)
      final alwaysFail = FlakyLocal(testDb: db, failCount: 10);
      final model = TransactionModel(
        warehouseId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 100,
        totalQty: 1,
      );

      try {
        await alwaysFail.insertSyncTransaction(model);
        fail('Expected exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
