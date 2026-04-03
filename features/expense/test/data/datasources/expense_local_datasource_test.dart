import 'package:expense/data/datasources/db/expense.table.dart';
import 'package:expense/data/datasources/expense_local.datasource.dart';
import 'package:expense/data/models/expense.model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database testDb;
  late ExpenseLocalDataSource localDataSource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    testDb = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(ExpenseTable.createTableQuery);
        await db.execute(ExpenseTable.createIndexDate);
      },
    );
    localDataSource = ExpenseLocalDataSource(testDb: testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  group('ExpenseLocalDataSource - getExpenses', () {
    test('mengembalikan list kosong bila belum ada data', () async {
      final result = await localDataSource.getExpenses();

      expect(result, isEmpty);
    });

    test('mengembalikan semua expense yang tersimpan di lokal', () async {
      await localDataSource.insertExpense(
        ExpenseModel(
          categoryName: 'Gas',
          qty: 1,
          totalAmount: 30000,
          notes: 'Beli gas 3kg',
          createdAt: DateTime.now(),
        ),
      );
      await localDataSource.insertExpense(
        ExpenseModel(
          categoryName: 'Listrik',
          qty: null,
          totalAmount: 200000,
          createdAt: DateTime.now(),
        ),
      );

      final result = await localDataSource.getExpenses();

      expect(result.length, equals(2));
      expect(result.map((e) => e.categoryName),
          containsAll(['Gas', 'Listrik']));
    });
  });

  group('ExpenseLocalDataSource - insertExpense', () {
    test('insert berhasil dan mengembalikan model dengan id', () async {
      final model = ExpenseModel(
        categoryName: 'Parkir',
        qty: 1,
        totalAmount: 5000,
        notes: 'Parkir kantor',
        createdAt: DateTime.now(),
      );

      final result = await localDataSource.insertExpense(model);

      expect(result, isNotNull);
      expect(result!.id, isNotNull);
      expect(result.id, greaterThan(0));
      expect(result.categoryName, equals('Parkir'));
      expect(result.totalAmount, equals(5000));
    });

    test('insert model tanpa notes tidak menyebabkan error', () async {
      final model = ExpenseModel(
        categoryName: 'Bahan Baku',
        totalAmount: 75000,
        createdAt: DateTime.now(),
      );

      final result = await localDataSource.insertExpense(model);

      expect(result, isNotNull);
      expect(result!.notes, isNull);
    });

    test('insert dua expense menghasilkan id berbeda', () async {
      final first = await localDataSource.insertExpense(
        ExpenseModel(categoryName: 'A', totalAmount: 1000),
      );
      final second = await localDataSource.insertExpense(
        ExpenseModel(categoryName: 'B', totalAmount: 2000),
      );

      expect(first!.id, isNot(equals(second!.id)));
    });
  });

  group('ExpenseLocalDataSource - updateExpense', () {
    test('update berhasil mengubah data yang ada', () async {
      final inserted = await localDataSource.insertExpense(
        ExpenseModel(
          categoryName: 'Original',
          totalAmount: 10000,
          createdAt: DateTime.now(),
        ),
      );

      final rows = await localDataSource.updateExpense({
        'id': inserted!.id,
        'category_name': 'Updated',
        'total_amount': 99999,
      });

      expect(rows, equals(1));

      final updated = await localDataSource.getExpenses();
      expect(updated.first.categoryName, equals('Updated'));
      expect(updated.first.totalAmount, equals(99999));
    });
  });

  group('ExpenseLocalDataSource - clearSyncedAt', () {
    test('clearSyncedAt menghapus nilai synced_at menjadi null', () async {
      final now = DateTime.now();
      final inserted = await localDataSource.insertExpense(
        ExpenseModel(
          categoryName: 'Synced',
          totalAmount: 5000,
          syncedAt: now,
          createdAt: now,
        ),
      );

      await localDataSource.clearSyncedAt(inserted!.id!);

      final rows = await testDb.query(
        ExpenseTable.tableName,
        where: '${ExpenseTable.colId} = ?',
        whereArgs: [inserted.id],
        limit: 1,
      );
      expect(rows.first[ExpenseTable.colSyncedAt], isNull);
    });
  });
}
