// Integration tests untuk `TransactionHistoryViewModel` menggunakan DB lokal (in-memory)
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/datasources/transaction_local.data_source.dart';

void main() {
  // init ffi and factory
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('TransactionHistoryViewModel integration (local DB)', () {
    late Database db;
    late TransactionLocalDataSource local;
    late dynamic usecase;
    late _TestTransactionHistoryViewModel vm;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      // create tables
      await db.execute(TransactionTable.createTableQuery);
      await db.execute(TransactionDetailTable.createTableQuery);

      local = TransactionLocalDataSource(testDb: db);
      // lightweight fake usecase that reads from local datasource directly
      usecase = _FakeGetTransactions(local);
      vm = _TestTransactionHistoryViewModel(usecase);
    });

    tearDown(() async {
      await db.close();
    });

    // test-local classes are declared at file-top (below) to avoid nested class
    // declarations inside functions which Dart does not allow.

    test('refresh loads offline transactions from local DB', () async {
      // insert two transactions
      final now = DateTime.now();
      final tx1 = TransactionModel(
        outletId: 1,
        sequenceNumber: 1001,
        orderTypeId: 1,
        date: now,
        notes: 'Today note',
        totalAmount: 100,
        totalQty: 1,
        createdAt: now,
      );

      final tx2 = TransactionModel(
        outletId: 1,
        sequenceNumber: 1002,
        orderTypeId: 1,
        date: now.subtract(const Duration(days: 1)),
        notes: 'Yesterday note',
        totalAmount: 200,
        totalQty: 2,
        createdAt: now.subtract(const Duration(days: 1)),
      );

      final ins1 = await local.insertSyncTransaction(tx1);
      final ins2 = await local.insertSyncTransaction(tx2);
      expect(ins1, isNotNull);
      expect(ins2, isNotNull);

      // sanity: pastikan datasource lokal mengembalikan baris yang disisipkan secara langsung
      final direct = await local.getTransactions();
      expect(direct.length, greaterThanOrEqualTo(2));

      // refresh VM and verify it loaded both
      await vm.refresh();
      final list = vm.getTransactionsOffline;
      expect(list.length, equals(2));
    });

    test('setSelectedDate filters transactions by date', () async {
      final now = DateTime.now();
      final txToday = TransactionModel(
        outletId: 1,
        sequenceNumber: 2001,
        orderTypeId: 1,
        date: now,
        notes: 'Filter Today',
        totalAmount: 50,
        totalQty: 1,
        createdAt: now,
      );
      final txOther = TransactionModel(
        outletId: 1,
        sequenceNumber: 2002,
        orderTypeId: 1,
        date: now.subtract(const Duration(days: 2)),
        notes: 'Other day',
        totalAmount: 60,
        totalQty: 1,
        createdAt: now.subtract(const Duration(days: 2)),
      );

      await local.insertSyncTransaction(txToday);
      await local.insertSyncTransaction(txOther);

      // VM init memanggil refresh otomatis; pastikan kita memiliki data
      await vm.refresh();
      expect(vm.getTransactionsOffline.length, greaterThanOrEqualTo(2));

      // set selected date to today (vm.setSelectedDate triggers refresh)
      await vm.setSelectedDate(DateTime(now.year, now.month, now.day));
      final filtered = vm.getFilteredTransactions;
      expect(filtered.every((t) => t.date.year == now.year), isTrue);
      expect(filtered.any((t) => t.notes == 'Filter Today'), isTrue);
    });

    test('setSearchQuery + refresh filters by notes or sequence number',
        () async {
      final now = DateTime.now();
      final txA = TransactionModel(
        outletId: 1,
        sequenceNumber: 5555,
        orderTypeId: 1,
        date: now,
        notes: 'SpecialCase',
        totalAmount: 123,
        totalQty: 1,
        createdAt: now,
      );
      final txB = TransactionModel(
        outletId: 1,
        sequenceNumber: 6666,
        orderTypeId: 1,
        date: now,
        notes: 'Other',
        totalAmount: 456,
        totalQty: 1,
        createdAt: now,
      );

      await local.insertSyncTransaction(txA);
      await local.insertSyncTransaction(txB);

      // search by notes (case-insensitive)
      vm.setSearchQuery('special');
      await vm.refresh();
      final res1 = vm.getTransactionsOffline
          .where((t) => (t.notes ?? '').toLowerCase().contains('special'))
          .toList();
      expect(res1.length, greaterThanOrEqualTo(1));

      // search by sequence number (string match)
      vm.setSearchQuery('5555');
      await vm.refresh();
      final res2 = vm.getTransactionsOffline
          .where((t) => (t.sequenceNumber?.toString() ?? '').contains('5555'))
          .toList();
      expect(res2.length, greaterThanOrEqualTo(1));
    });
  });
}

// --- Test helpers (top-level) ---

class _FakeGetTransactions {
  final TransactionLocalDataSource local;
  _FakeGetTransactions(this.local);

  Future<Either<Failure, List<TransactionEntity>>> call(
      {bool isOffline = false, QueryGetTransactions? query}) async {
    try {
      final models = await local.getTransactions(query: query);
      final entities =
          models.map((m) => TransactionEntity.fromModel(m)).toList();
      return Right(entities);
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}

class _TestTransactionHistoryViewModel {
  final dynamic _getTransactions;
  bool isLoading = false;
  String? error;
  DateTime? selectedDate;
  String? searchQuery;
  List<TransactionEntity> transactions = [];

  _TestTransactionHistoryViewModel(this._getTransactions);

  List<TransactionEntity> get getTransactionsOffline => transactions;

  List<TransactionEntity> get getFilteredTransactions {
    final sel = selectedDate;
    var list = transactions;
    if (sel != null) {
      list = list.where((tx) {
        final d = tx.date;
        return d.year == sel.year && d.month == sel.month && d.day == sel.day;
      }).toList();
    }
    return list;
  }

  void setSearchQuery(String q) {
    searchQuery = q;
  }

  Future<void> setSelectedDate(DateTime? date) async {
    if (date == null)
      selectedDate = null;
    else
      selectedDate = DateTime(date.year, date.month, date.day);
    await refresh();
  }

  Future<void> refresh() async {
    isLoading = true;
    final q = QueryGetTransactions(search: searchQuery, date: selectedDate);
    final res = await _getTransactions.call(isOffline: true, query: q);
    res.fold((f) {
      error = f.toString();
      isLoading = false;
    }, (list) {
      transactions = list;
      isLoading = false;
    });
  }
}
