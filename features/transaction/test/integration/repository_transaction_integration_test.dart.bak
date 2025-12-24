import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// sqlite_api re-exported by sqflite_common_ffi
import 'package:transaction/data/datasources/transaction_local.data_source.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/repositories/transaction.repository_impl.dart';
import 'package:transaction/data/datasources/transaction_remote.data_source.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/responses/transaction.response.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';

class FakeRemote extends TransactionRemoteDataSource {
  FakeRemote() : super(host: 'http://localhost', api: 'test');
  @override
  Future<TransactionResponse> postTransaction(
      Map<String, dynamic> payload) async {
    // simulate server creating with id_server
    final created = TransactionModel.fromJson(payload).copyWith(idServer: 99);
    return TransactionResponse(success: true, message: '', data: [created]);
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('TransactionRepositoryImpl integration (offline create)', () {
    late Database db;
    late TransactionLocalDataSource local;
    late TransactionRepositoryImpl repo;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);
      local = TransactionLocalDataSource(testDb: db);
      repo = TransactionRepositoryImpl(remote: FakeRemote(), local: local);
    });

    tearDown(() async {
      await db.close();
    });

    test('createTransaction with isOffline true stores locally', () async {
      final txEntity = TransactionEntity(
        outletId: 5,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 4000,
        totalQty: 1,
      );

      final res = await repo.createTransaction(txEntity, isOffline: true);
      expect(res.isRight(), true);
      // perform DB assertions after ensuring repo call completed
      final dao = TransactionDao(db);
      final list = await dao.getTransactions();
      expect(list, isNotEmpty);
      expect(list.first.totalAmount, equals(4000));
    });

    test('updateTransaction with isOffline true updates local row', () async {
      final txEntity = TransactionEntity(
        outletId: 5,
        sequenceNumber: 2,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 7000,
        totalQty: 1,
      );

      final createRes = await repo.createTransaction(txEntity, isOffline: true);
      expect(createRes.isRight(), true);
      final created =
          createRes.getOrElse(() => throw Exception('create failed'));

      // modify notes and update
      final updatedEntity = created.copyWith(notes: 'updated-test');
      final updRes =
          await repo.updateTransaction(updatedEntity, isOffline: true);
      expect(updRes.isRight(), true);

      final dao = TransactionDao(db);
      final fetched = await dao.getTransactionById(created.id!);
      expect(fetched, isNotNull);
      expect(fetched!.notes, equals('updated-test'));
    });

    test('deleteTransaction with isOffline true removes local row', () async {
      final txEntity = TransactionEntity(
        outletId: 6,
        sequenceNumber: 3,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 9000,
        totalQty: 1,
      );

      final createRes = await repo.createTransaction(txEntity, isOffline: true);
      expect(createRes.isRight(), true);
      final created =
          createRes.getOrElse(() => throw Exception('create failed'));

      final delRes =
          await repo.deleteTransaction(created.id ?? 0, isOffline: true);
      expect(delRes.isRight(), true);

      final dao = TransactionDao(db);
      final fetched = await dao.getTransactionById(created.id!);
      expect(fetched, isNull);
    });
  });
}
