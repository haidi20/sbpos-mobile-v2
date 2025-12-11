import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// sqlite_api re-exported by sqflite_common_ffi
import 'package:transaction/data/datasources/transaction_local_data_source.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('TransactionLocalDataSource integration', () {
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

    test('insertTransaction and insertDetails', () async {
      final model = TransactionModel(
        outletId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 2000,
        totalQty: 1,
      );

      final inserted = await local.insertTransaction(model);
      expect(inserted, isNotNull);

      final detail = TransactionDetailModel(
        transactionId: inserted!.id,
        productId: 5,
        productName: 'X',
        productPrice: 2000,
        qty: 1,
        subtotal: 2000,
      );

      final details = await local.insertDetails([detail]);
      expect(details, isNotNull);
      expect(details!.first.transactionId, equals(inserted.id));
    });

    test('insertSyncTransaction stores transaction and details', () async {
      final model = TransactionModel(
        outletId: 2,
        sequenceNumber: 2,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 3000,
        totalQty: 1,
        details: [
          TransactionDetailModel(
            productId: 6,
            productName: 'Y',
            productPrice: 3000,
            qty: 1,
            subtotal: 3000,
          )
        ],
      );

      final inserted = await local.insertSyncTransaction(model);
      expect(inserted, isNotNull);
      expect(inserted!.details, isNotNull);
      expect(inserted.details!.first.transactionId, equals(inserted.id));
    });
  });
}
