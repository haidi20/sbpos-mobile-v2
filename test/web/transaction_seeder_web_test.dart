import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:core/data/datasources/local_database_sembast.dart'
    as sembast_db;

void main() {
  test('web transaction seeder: insert tx + details into sembast web DB',
      () async {
    if (!kIsWeb) return;
    await sembast_db.LocalDatabase.instance.init('web_test_tx.db');
    await sembast_db.LocalDatabase.instance
        .deleteAll(TransactionTable.tableName);
    await sembast_db.LocalDatabase.instance
        .deleteAll(TransactionDetailTable.tableName);

    final tx =
        TransactionModel(totalAmount: 200, totalQty: 1).toInsertDbLocal();
    final txId = await sembast_db.LocalDatabase.instance
        .insert(TransactionTable.tableName, tx);
    expect(txId, isNotNull);

    final detail = {
      'transaction_id': txId,
      'product_id': 1,
      'product_name': 'Web Seeder Product',
      'product_price': 200,
      'qty': 1,
      'subtotal': 200,
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
  });
}
