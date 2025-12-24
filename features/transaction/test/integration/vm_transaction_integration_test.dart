import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// sqlite_api re-exported by sqflite_common_ffi
import 'package:transaction/data/datasources/transaction_local.data_source.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/repositories/transaction.repository_impl.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/data/datasources/transaction_remote.data_source.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';

class FakeRemote extends TransactionRemoteDataSource {
  FakeRemote() : super(host: 'http://localhost', api: 'test');
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('TransactionPosViewModel integration (end-to-end local DB)', () {
    late Database db;
    late TransactionLocalDataSource local;
    late TransactionRepositoryImpl repo;
    late TransactionPosViewModel vm;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);
      local = TransactionLocalDataSource(testDb: db);
      repo = TransactionRepositoryImpl(remote: FakeRemote(), local: local);
      vm = TransactionPosViewModel(
        CreateTransaction(repo),
        UpdateTransaction(repo),
        DeleteTransaction(repo),
        GetTransactionActive(repo),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('onAddToCart + onStoreLocal persists to local DB', () async {
      const product = ProductEntity(id: 21, name: 'VMProd', price: 12000.0);
      // add to cart (await because onAddToCart persists to DB first)
      await vm.onAddToCart(product);

      // verify VM state
      expect(vm.state.transaction, isNotNull);
      expect(vm.state.transaction?.toModel().toJson()['id'], isNotNull);

      // verify DB
      final dao = TransactionDao(db);
      final txs = await dao.getTransactions();
      expect(txs, isNotEmpty);
      expect(txs.first.totalAmount, equals(12000));
    });

    test('setUpdateQuantity updates DB transaction totals and detail qty',
        () async {
      const product = ProductEntity(id: 22, name: 'VMProd2', price: 15000.0);
      // add and persist
      await vm.onAddToCart(product);

      final txId = vm.state.transaction?.id;
      expect(txId, isNotNull);
      final txIdNonNull = txId!;

      // increase qty by 1 (from 1 -> 2)
      await vm.setUpdateQuantity(22, 1);

      final dao = TransactionDao(db);
      final fetched = await dao.getTransactionById(txIdNonNull);
      expect(fetched, isNotNull);
      final fetchedModel = fetched!;
      // totalQty harus diperbarui menjadi 2 dan totalAmount = 15000 * 2
      expect(fetchedModel.totalQty, equals(2));
      expect(fetchedModel.totalAmount, equals(15000 * 2));

      // qty detail harus bernilai 2
      final details = await dao.getDetailsByTransactionId(txIdNonNull);
      expect(details, isNotEmpty);
      final detailsList = details;
      expect(detailsList.first.qty, equals(2));
    });
  });
}
