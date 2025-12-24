import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';

// Native imports
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.io) 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Web (sembast) import
import 'package:core/data/datasources/local_database_sembast.dart'
    as sembast_db;

void main() {
  test('transaction seeder: insert transaction + details into local DB',
      () async {
    if (kIsWeb) {
      await sembast_db.LocalDatabase.instance.init('test_tx.db');
      await sembast_db.LocalDatabase.instance
          .deleteAll(TransactionTable.tableName);
      await sembast_db.LocalDatabase.instance
          .deleteAll(TransactionDetailTable.tableName);

      final tx =
          TransactionModel(totalAmount: 1000, totalQty: 2).toInsertDbLocal();
      final txId = await sembast_db.LocalDatabase.instance
          .insert(TransactionTable.tableName, tx);
      expect(txId, isNotNull);

      final detail = {
        'transaction_id': txId,
        'product_id': 1,
        'product_name': 'Seeder Product',
        'product_price': 500,
        'qty': 2,
        'subtotal': 1000,
      };
      final detailId = await sembast_db.LocalDatabase.instance
          .insert(TransactionDetailTable.tableName, detail);
      expect(detailId, isNotNull);

      final txs = await sembast_db.LocalDatabase.instance
          .getAll(TransactionTable.tableName);
      final details = await sembast_db.LocalDatabase.instance.getWhereEquals(
          TransactionDetailTable.tableName, 'transaction_id', txId);
      expect(txs.length, greaterThanOrEqualTo(1));
      expect(details.length, greaterThanOrEqualTo(1));

      await sembast_db.LocalDatabase.instance
          .deleteAll(TransactionTable.tableName);
      await sembast_db.LocalDatabase.instance
          .deleteAll(TransactionDetailTable.tableName);
      await sembast_db.LocalDatabase.instance.close();
    } else {
      // Native path: sqlite in-memory via ffi
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);

      final dao = TransactionDao(db);
      final txMap =
          TransactionModel(totalAmount: 1000, totalQty: 2).toInsertDbLocal();
      final details = [
        {
          'product_id': 1,
          'product_name': 'Seeder Product',
          'product_price': 500,
          'qty': 2,
          'subtotal': 1000,
        }
      ];

      final inserted = await dao.insertSyncTransaction(txMap, details);
      expect(inserted.id, isNotNull);
      expect(inserted.details?.length ?? 0, equals(1));

      final txRows = await db.query(TransactionTable.tableName);
      final detailRows = await db.query(TransactionDetailTable.tableName);
      expect(txRows.length, greaterThanOrEqualTo(1));
      expect(detailRows.length, greaterThanOrEqualTo(1));

      await db.close();
    }
  });
}
