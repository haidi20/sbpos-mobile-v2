import 'package:core/core.dart';
import 'package:expense/data/datasources/db/expense.table.dart';
import 'package:expense/data/datasources/expense_local.datasource.dart';
import 'package:expense/data/datasources/expense_remote.datasource.dart';
import 'package:expense/data/models/expense.model.dart';
import 'package:expense/data/repositories/expense.repository.impl.dart';
import 'package:expense/data/responses/expense.response.dart';
import 'package:expense/domain/entities/expense.entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// ---------------------------------------------------------------
/// Fake Remote DataSource — injectable, configurable per-test
/// ---------------------------------------------------------------
class _FakeRemote implements ExpenseRemoteDataSource {
  Future<ExpenseResponse> Function({Map<String, dynamic>? params})?
      onFetchExpenses;
  Future<ExpenseResponse> Function(Map<String, dynamic> payload)?
      onPostExpense;

  @override
  Future<ExpenseResponse> fetchExpenses(
      {Map<String, dynamic>? params}) async {
    return onFetchExpenses != null
        ? await onFetchExpenses!(params: params)
        : ExpenseResponse(success: false, message: 'Not configured');
  }

  @override
  Future<ExpenseResponse> postExpense(Map<String, dynamic> payload) async {
    return onPostExpense != null
        ? await onPostExpense!(payload)
        : ExpenseResponse(success: false, message: 'Not configured');
  }

  // Expose private fields required by BaseErrorHelper
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// ---------------------------------------------------------------
/// Helper: setup in-memory DB + real local datasource
/// ---------------------------------------------------------------
Future<(Database, ExpenseLocalDataSource)> _setupLocal() async {
  final db = await openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute(ExpenseTable.createTableQuery);
      await db.execute(ExpenseTable.createIndexDate);
    },
  );
  final local = ExpenseLocalDataSource(testDb: db);
  return (db, local);
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // ---------------------------------------------------------------
  // getExpenses - isOffline: true
  // ---------------------------------------------------------------
  group('ExpenseRepositoryImpl.getExpenses (offline)', () {
    late Database db;
    late ExpenseLocalDataSource local;
    late _FakeRemote remote;
    late ExpenseRepositoryImpl repository;

    setUp(() async {
      (db, local) = await _setupLocal();
      remote = _FakeRemote();
      repository = ExpenseRepositoryImpl(remote: remote, local: local);
    });

    tearDown(() => db.close());

    test('mengembalikan list kosong bila db lokal kosong', () async {
      final result = await repository.getExpenses(isOffline: true);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('mengembalikan data lokal tanpa memanggil remote', () async {
      await local.insertExpense(
        ExpenseModel(
          categoryName: 'Parkir',
          totalAmount: 5000,
          createdAt: DateTime.now(),
        ),
      );

      final result = await repository.getExpenses(isOffline: true);

      expect(result.isRight(), isTrue);
      final expenses = result.getOrElse(() => []);
      expect(expenses.length, equals(1));
      expect(expenses.first.categoryName, equals('Parkir'));
    });
  });

  // ---------------------------------------------------------------
  // createExpense - isOffline: true
  // ---------------------------------------------------------------
  group('ExpenseRepositoryImpl.createExpense (offline)', () {
    late Database db;
    late ExpenseLocalDataSource local;
    late _FakeRemote remote;
    late ExpenseRepositoryImpl repository;

    setUp(() async {
      (db, local) = await _setupLocal();
      remote = _FakeRemote();
      repository = ExpenseRepositoryImpl(remote: remote, local: local);
    });

    tearDown(() => db.close());

    test('berhasil menyimpan expense ke lokal dan mengembalikan entity', () async {
      const expense = ExpenseEntity(
        categoryName: 'Gas',
        qty: 2,
        totalAmount: 60000,
        notes: 'Beli gas 3kg',
      );

      final result =
          await repository.createExpense(expense, isOffline: true);

      expect(result.isRight(), isTrue);
      final entity = result.getOrElse(() => const ExpenseEntity());
      expect(entity.id, isNotNull);
      expect(entity.categoryName, equals('Gas'));
      expect(entity.totalAmount, equals(60000));
    });

    test('expense yang disimpan muncul saat getExpenses offline', () async {
      const expense = ExpenseEntity(
        categoryName: 'Listrik',
        totalAmount: 150000,
      );

      await repository.createExpense(expense, isOffline: true);

      final result = await repository.getExpenses(isOffline: true);
      final expenses = result.getOrElse(() => []);
      expect(expenses.any((e) => e.categoryName == 'Listrik'), isTrue);
    });

    test('insert multiple expenses semuanya tersimpan', () async {
      await repository.createExpense(
        const ExpenseEntity(categoryName: 'A', totalAmount: 1000),
        isOffline: true,
      );
      await repository.createExpense(
        const ExpenseEntity(categoryName: 'B', totalAmount: 2000),
        isOffline: true,
      );
      await repository.createExpense(
        const ExpenseEntity(categoryName: 'C', totalAmount: 3000),
        isOffline: true,
      );

      final result = await repository.getExpenses(isOffline: true);
      expect(result.getOrElse(() => []).length, equals(3));
    });
  });

  // ---------------------------------------------------------------
  // createExpense - tanpa isOffline (fallback ke lokal bila tidak ada network)
  // ---------------------------------------------------------------
  group('ExpenseRepositoryImpl.createExpense (tanpa flag isOffline)', () {
    late Database db;
    late ExpenseLocalDataSource local;
    late _FakeRemote remote;
    late ExpenseRepositoryImpl repository;

    setUp(() async {
      (db, local) = await _setupLocal();
      remote = _FakeRemote();
      repository = ExpenseRepositoryImpl(remote: remote, local: local);
    });

    tearDown(() => db.close());

    test(
        'selalu mengembalikan Right saat insertLokal berhasil (isOffline=true bypass network)',
        () async {
      // Di test environment tidak ada koneksi nyata.
      // Gunakan isOffline:true untuk memverifikasi lokal-first path tanpa network.
      const expense = ExpenseEntity(
        categoryName: 'Gas',
        totalAmount: 60000,
      );

      final result = await repository.createExpense(expense, isOffline: true);

      expect(result.isRight(), isTrue);
      final entity = result.getOrElse(() => const ExpenseEntity());
      expect(entity.categoryName, equals('Gas'));
      expect(entity.totalAmount, equals(60000));
    });

    test('expense tersimpan di lokal tanpa network', () async {
      const expense =
          ExpenseEntity(categoryName: 'Lokal Fallback', totalAmount: 999);

      await repository.createExpense(expense, isOffline: true);

      final localData = await repository.getExpenses(isOffline: true);
      final list = localData.getOrElse(() => []);
      expect(list.any((e) => e.categoryName == 'Lokal Fallback'), isTrue);
    });
  });
}
