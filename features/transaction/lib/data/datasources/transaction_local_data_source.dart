import 'dart:typed_data';
import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:transaction/data/models/transaction_model.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';

/// Data source lokal untuk operasi DB transaksi.
/// Mengikuti pola `WarehouseLocalDataSource`.
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

  /// Optional [testDb] can be provided for integration tests to use an
  /// in-memory or injected database instance. When provided, the helper
  /// will use it instead of the global CoreDatabase.
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

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database gagal dibuka/null');
        return [];
      }
      final query = createDao(db);
      final result = await query.getTransactions();
      _logInfo('getTransactions: success count=${result.length}');
      return result;
    } catch (e, st) {
      _logSevere('Error getTransactions', e, st);
      return [];
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
      final sanitized = _sanitizeForDb(raw);
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

      final txMap = _sanitizeForDb(txMapRaw);
      final detailsMaps = detailsMapsRaw.map(_sanitizeForDb).toList();
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
      final maps = details.map((d) => d.toInsertDbLocal()).toList();
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
      final result = await query.updateTransaction(tx);
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

  /// Overridable factory for DAO to support testing (e.g. injecting flaky DAO).
  @visibleForTesting
  TransactionDao createDao(Database db) => TransactionDao(db);

  /// Ensure the map only contains values supported by sqflite (num, String, Uint8List).
  /// - Converts DateTime to ISO string
  /// - Converts bool to integer (1/0)
  /// - Encodes Map/Iterable to JSON string
  /// - Drops keys with null values to avoid passing raw `Null` into sqflite
  Map<String, dynamic> _sanitizeForDb(Map<String, dynamic> src) {
    final out = <String, dynamic>{};
    src.forEach((key, value) {
      if (value == null) {
        return; // skip nulls to avoid sqflite unsupported-type warnings
      }
      if (value is DateTime) {
        out[key] = value.toIso8601String();
      } else if (value is bool) {
        out[key] = value ? 1 : 0;
      } else if (value is num || value is String || value is Uint8List) {
        out[key] = value;
      } else if (value is Map || value is Iterable) {
        try {
          out[key] = jsonEncode(value);
        } catch (_) {
          out[key] = value.toString();
        }
      } else {
        // fallback to string representation
        out[key] = value.toString();
      }
    });
    return out;
  }
}
