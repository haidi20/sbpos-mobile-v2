import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';
import 'package:transaction/data/models/transaction.model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('TransactionDao integration', () {
    late Database db;
    late TransactionDao dao;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);
      dao = TransactionDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertSyncTransaction and getTransactions', () async {
      final txMap = TransactionModel(
        warehouseId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 5000,
        totalQty: 1,
      ).toInsertDbLocal();

      final detail = TransactionDetailModel(
        productId: 10,
        productName: 'Prod',
        productPrice: 5000,
        qty: 1,
        subtotal: 5000,
      ).toInsertDbLocal();

      final inserted = await dao.insertSyncTransaction(txMap, [detail]);
      expect(inserted.id, isNotNull);
      final all = await dao.getTransactions();
      expect(all, isNotEmpty);
      final fetched = await dao.getTransactionById(inserted.id!);
      expect(fetched, isNotNull);
      expect(fetched!.details, isNotEmpty);
    });

    test('updateTransaction and delete', () async {
      final txMap = TransactionModel(
        warehouseId: 1,
        sequenceNumber: 2,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 10000,
        totalQty: 2,
      ).toInsertDbLocal();

      final inserted = await dao.insertSyncTransaction(txMap, []);
      final id = inserted.id!;
      final upd = await dao.updateTransaction({'id': id, 'notes': 'updated'});
      expect(upd, isNonZero);
      final deleted = await dao.deleteTransaction(id);
      expect(deleted, equals(1));
    });

    test('insertDetails upserts by transaction_id + product_id', () async {
      // create empty transaction
      final txMap = TransactionModel(
        warehouseId: 1,
        sequenceNumber: 3,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 0,
        totalQty: 0,
      ).toInsertDbLocal();

      final insertedTx = await dao.insertSyncTransaction(txMap, []);
      final txId = insertedTx.id!;

      final detailMap = TransactionDetailModel(
        productId: 42,
        productName: 'Widget',
        productPrice: 100,
        qty: 1,
        subtotal: 100,
      ).toInsertDbLocal();

      // ensure transaction id is set on detail map
      detailMap[TransactionDetailTable.colTransactionId] = txId;

      // first insert
      final first = await dao.insertDetails([detailMap]);
      expect(first, isNotEmpty);
      expect(first.first.qty, equals(1));

      // second insert of same product -> should update existing row (qty becomes 2)
      final second = await dao.insertDetails([detailMap]);
      expect(second, isNotEmpty);
      // verify DB has only one detail for this tx and product with qty == 2
      final fetched = await dao.getTransactionById(txId);
      expect(fetched, isNotNull);
      final detailsForProduct =
          (fetched!.details ?? []).where((d) => d.productId == 42).toList();
      expect(detailsForProduct.length, equals(1));
      expect(detailsForProduct.first.qty, equals(2));
    });

    test('insertDetails sanitizes null values before DB write', () async {
      final txMap = TransactionModel(
        warehouseId: 1,
        sequenceNumber: 4,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 0,
        totalQty: 0,
      ).toInsertDbLocal();

      final insertedTx = await dao.insertSyncTransaction(txMap, []);
      final txId = insertedTx.id!;

      // create detail map with some null fields
      final detailMap = TransactionDetailModel(
        productId: 55,
        productName: null,
        productPrice: null,
        qty: 1,
        subtotal: 0,
      ).toInsertDbLocal();
      detailMap[TransactionDetailTable.colTransactionId] = txId;

      // this should not throw and should insert without causing sqflite null-arg warning
      final inserted = await dao.insertDetails([detailMap]);
      expect(inserted, isNotEmpty);
      expect(inserted.first.productId, equals(55));
      expect(inserted.first.qty, equals(1));
    });
  });
}
