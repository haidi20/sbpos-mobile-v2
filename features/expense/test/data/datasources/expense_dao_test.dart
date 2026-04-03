import 'package:expense/data/datasources/db/expense.dao.dart';
import 'package:expense/data/datasources/db/expense.table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late ExpenseDao dao;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(ExpenseTable.createTableQuery);
        await db.execute(ExpenseTable.createIndexDate);
      },
    );
    dao = ExpenseDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ExpenseDao - getExpenses', () {
    test('mengembalikan list kosong bila tabel kosong', () async {
      final result = await dao.getExpenses();

      expect(result, isEmpty);
    });

    test('mengembalikan semua expense yang sudah di-insert', () async {
      await dao.insertExpense({
        'category_name': 'Listrik',
        'qty': 1,
        'total_amount': 150000,
        'notes': 'Bayar PLN',
        'created_at': DateTime(2025, 1, 15).toIso8601String(),
      });
      await dao.insertExpense({
        'category_name': 'Gas',
        'qty': 2,
        'total_amount': 50000,
        'notes': null,
        'created_at': DateTime(2025, 1, 10).toIso8601String(),
      });

      final result = await dao.getExpenses();

      expect(result.length, equals(2));
    });

    test('mengurutkan expense terbaru di urutan pertama (DESC)', () async {
      await dao.insertExpense({
        'category_name': 'Lama',
        'total_amount': 10000,
        'created_at': DateTime(2025, 1, 1).toIso8601String(),
      });
      await dao.insertExpense({
        'category_name': 'Baru',
        'total_amount': 20000,
        'created_at': DateTime(2025, 1, 20).toIso8601String(),
      });

      final result = await dao.getExpenses();

      expect(result.first.categoryName, equals('Baru'));
      expect(result.last.categoryName, equals('Lama'));
    });
  });

  group('ExpenseDao - insertExpense', () {
    test('berhasil insert dan mengembalikan model dengan id auto-increment',
        () async {
      final inserted = await dao.insertExpense({
        'category_name': 'Parkir',
        'qty': 1,
        'total_amount': 5000,
        'notes': 'Parkir motor',
        'created_at': DateTime.now().toIso8601String(),
      });

      expect(inserted.id, isNotNull);
      expect(inserted.id, greaterThan(0));
      expect(inserted.categoryName, equals('Parkir'));
      expect(inserted.totalAmount, equals(5000));
      expect(inserted.notes, equals('Parkir motor'));
    });

    test('insert beberapa expense menghasilkan id unik berbeda', () async {
      final first = await dao.insertExpense({
        'category_name': 'A',
        'total_amount': 1000,
      });
      final second = await dao.insertExpense({
        'category_name': 'B',
        'total_amount': 2000,
      });

      expect(first.id, isNot(equals(second.id)));
    });

    test('insert tanpa field opsional tidak menyebabkan error', () async {
      final inserted = await dao.insertExpense({
        'category_name': 'Minimal',
        'total_amount': 1000,
      });

      expect(inserted.id, isNotNull);
      expect(inserted.qty, isNull);
      expect(inserted.notes, isNull);
    });
  });

  group('ExpenseDao - updateExpense', () {
    test('berhasil mengupdate data expense yang ada', () async {
      final inserted = await dao.insertExpense({
        'category_name': 'Awal',
        'total_amount': 1000,
      });

      final rowsAffected = await dao.updateExpense({
        'id': inserted.id,
        'category_name': 'Sudah Diupdate',
        'total_amount': 99000,
      });

      expect(rowsAffected, equals(1));

      final rows = await db.query(
        ExpenseTable.tableName,
        where: '${ExpenseTable.colId} = ?',
        whereArgs: [inserted.id],
        limit: 1,
      );
      expect(rows.first['category_name'], equals('Sudah Diupdate'));
      expect(rows.first['total_amount'], equals(99000));
    });

    test('update dengan id tidak ada mengembalikan 0 rows affected', () async {
      final rowsAffected = await dao.updateExpense({
        'id': 9999,
        'category_name': 'Tidak Ada',
      });

      expect(rowsAffected, equals(0));
    });
  });

  group('ExpenseDao - clearSyncedAt', () {
    test('berhasil menghapus synced_at menjadi NULL', () async {
      final inserted = await dao.insertExpense({
        'category_name': 'Synced',
        'total_amount': 5000,
        'synced_at': DateTime.now().toIso8601String(),
      });

      await dao.clearSyncedAt(inserted.id!);

      final rows = await db.query(
        ExpenseTable.tableName,
        where: '${ExpenseTable.colId} = ?',
        whereArgs: [inserted.id],
        limit: 1,
      );
      expect(rows.first['synced_at'], isNull);
    });

    test('clearSyncedAt dengan id tidak ada mengembalikan 0', () async {
      final count = await dao.clearSyncedAt(9999);

      expect(count, equals(0));
    });
  });
}
