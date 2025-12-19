// dart:typed_data not needed here
import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';

class TransactionLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final Database? _testDb;
  final _logger = Logger('TransactionLocalDataSource');
  final bool isShowLog = false;
  void _logInfo(String msg) {
    if (isShowLog) _logger.info(msg);
  }

  void _logFine(String msg) {
    if (isShowLog) _logger.fine(msg);
  }

  void _logWarning(String msg) {
    if (isShowLog) _logger.warning(msg);
  }

  void _logSevere(String msg, [Object? error, StackTrace? st]) {
    if (isShowLog) _logger.severe(msg, error, st);
  }

  /// [testDb] opsional dapat diberikan untuk pengujian integrasi agar menggunakan
  /// instance database in-memory atau yang di-inject. Jika disediakan, helper
  /// akan menggunakannya alih-alih CoreDatabase global.
  TransactionLocalDataSource({Database? testDb}) : _testDb = testDb;

  // Simple retry helper for transient DB exceptions (e.g., simulated disk issues)
  Future<T> _withRetry<T>(Future<T> Function() action,
      {int retries = 3,
      Duration delay = const Duration(milliseconds: 50)}) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt >= retries) rethrow;
        await Future.delayed(delay);
      }
    }
  }

  Future<List<TransactionModel>> getTransactions(
      {QueryGetTransactions? query}) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return [];
      }
      final dao = createDao(db);
      final result = await dao.getTransactions(query: query);
      _logInfo('getTransactions: success count=${result.length}');
      return result;
    } catch (e, st) {
      _logSevere('Error getTransactions', e, st);
      return [];
    }
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return null;
      }
      final query = createDao(db);
      // reuse getTransactions and filter or implement DAO helper
      final txs = await query.getTransactions();
      _logFine(
          'getTransactionById - fetched transactions count: ${txs.length}');
      for (final t in txs) {
        if (t.id == id) return t;
      }
      return null;
    } catch (e, st) {
      _logSevere('Error getTransactionById', e, st);
      rethrow;
    }
  }

  /// Returns the latest transaction (created_at desc) or null if none.
  Future<TransactionModel?> getPendingTransaction() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return null;
      }
      final query = createDao(db);
      final latest = await query.getPendingTransaction();
      return latest;
    } catch (e, st) {
      _logSevere('Error getPendingTransaction', e, st);
      rethrow;
    }
  }

  Future<TransactionModel?> insertTransaction(TransactionModel tx) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return null;
      }
      final query = createDao(db);
      final raw = tx.toInsertDbLocal();
      final sanitized = sanitizeForDb(raw);
      _logFine('insertTransaction - sanitized tx map: $sanitized');
      final inserted = await _withRetry(
        () async => await query.insertTransaction(
          sanitized,
        ),
      );
      _logInfo('insertTransaction: success id=${inserted.id}');

      return inserted;
    } catch (e, st) {
      _logSevere('Error insertTransaction', e, st);
      rethrow;
    }
  }

  /// Insert transaksi bersama details dalam satu operasi atomik.
  Future<TransactionModel?> insertSyncTransaction(TransactionModel tx) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return null;
      }

      final query = createDao(db);

      final txMapRaw = tx.toInsertDbLocal();
      final details = tx.details ?? [];
      final detailsMapsRaw = details.map((d) => d.toInsertDbLocal()).toList();

      final txMap = sanitizeForDb(txMapRaw);
      final detailsMaps = detailsMapsRaw.map(sanitizeForDb).toList();
      final inserted = await _withRetry(
          () async => await query.insertSyncTransaction(txMap, detailsMaps));
      _logFine('insertSyncTransaction - tx: $txMap');
      _logFine('insertSyncTransaction - details count: ${detailsMaps.length}');
      return inserted;
    } catch (e, st) {
      _logSevere('Error insertSyncTransaction', e, st);
      rethrow;
    }
  }

  Future<List<TransactionDetailModel>?> insertDetails(
      List<TransactionDetailModel> details) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return null;
      }
      final query = createDao(db);
      final maps =
          details.map((d) => sanitizeForDb(d.toInsertDbLocal())).toList();
      final inserted =
          await _withRetry(() async => await query.insertDetails(maps));
      final insertedCount = inserted.length;
      _logInfo('insertDetails: success count=$insertedCount');
      return inserted;
    } catch (e, st) {
      _logSevere('Error insertDetails', e, st);
      rethrow;
    }
  }

  Future<int> deleteDetailsByTransactionId(int txId) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return 0;
      }
      final query = createDao(db);
      final res = await query.deleteDetailsByTransactionId(txId);
      _logInfo('deleteDetailsByTransactionId: success txId=$txId rows=$res');
      return res;
    } catch (e, st) {
      _logSevere('Error deleteDetailsByTransactionId', e, st);
      rethrow;
    }
  }

  Future<int> updateTransaction(Map<String, dynamic> tx) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return 0;
      }
      final query = TransactionDao(db);
      final sanitized = sanitizeForDb(Map<String, dynamic>.from(tx));
      // keep id in map for DAO.updateTransaction to use; ensure it's present
      if (tx.containsKey('id')) sanitized['id'] = tx['id'];
      final result = await query.updateTransaction(sanitized);
      _logInfo('updateTransaction: success id=${tx['id']} rows=$result');
      return result;
    } catch (e, st) {
      _logSevere('Error updateTransaction', e, st);
      rethrow;
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return 0;
      }
      final query = createDao(db);
      final result = await query.deleteTransaction(id);
      _logInfo('deleteTransaction: success id=$id rows=$result');
      return result;
    } catch (e, st) {
      _logSevere('Error deleteTransaction', e, st);
      rethrow;
    }
  }

  Future<int> clearSyncedAt(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return 0;
      }
      final query = createDao(db);
      final res = await query.clearSyncedAt(id);
      _logInfo('clearSyncedAt: success id=$id rows=$res');
      return res;
    } catch (e, st) {
      _logSevere('Error clearSyncedAt', e, st);
      rethrow;
    }
  }

  /// Overridable factory for DAO to support testing (e.g. injecting flaky DAO).
  @visibleForTesting
  TransactionDao createDao(Database db) => TransactionDao(db);
}
