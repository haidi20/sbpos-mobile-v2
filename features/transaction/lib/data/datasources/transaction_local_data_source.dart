import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';
import 'package:transaction/data/models/transaction_model.dart';

/// Data source lokal untuk operasi DB transaksi.
/// Mengikuti pola `WarehouseLocalDataSource`.
class TransactionLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final _logger = Logger('TransactionLocalDataSource');

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return [];
      }
      final query = TransactionDao(db);
      final result = await query.getTransactions();
      return result;
    } catch (e, st) {
      _logger.severe('Error getTransactions', e, st);
      return [];
    }
  }

  Future<TransactionModel?> insertTransaction(TransactionModel tx) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return null;
      }
      final query = TransactionDao(db);
      final inserted = await query.insertTransaction(tx.toInsertDbLocal());
      return inserted;
    } catch (e, st) {
      _logger.severe('Error insertTransaction', e, st);
      rethrow;
    }
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return null;
      }
      final query = TransactionDao(db);
      // reuse getTransactions and filter or implement DAO helper
      final txs = await query.getTransactions();
      for (final t in txs) {
        if (t.id == id) return t;
      }
      return null;
    } catch (e, st) {
      _logger.severe('Error getTransactionById', e, st);
      rethrow;
    }
  }

  /// Insert transaksi bersama details dalam satu operasi atomik.
  Future<TransactionModel?> insertSyncTransaction(TransactionModel tx) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return null;
      }

      final query = TransactionDao(db);

      final txMap = tx.toInsertDbLocal();
      final details = tx.details ?? [];
      final detailsMaps = details.map((d) => d.toInsertDbLocal()).toList();

      final inserted = await query.insertSyncTransaction(txMap, detailsMaps);
      return inserted;
    } catch (e, st) {
      _logger.severe('Error insertSyncTransaction', e, st);
      rethrow;
    }
  }

  Future<List<TransactionDetailModel>?> insertDetails(
      List<TransactionDetailModel> details) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return null;
      }
      final query = TransactionDao(db);
      final maps = details.map((d) => d.toInsertDbLocal()).toList();
      final inserted = await query.insertDetails(maps);
      return inserted;
    } catch (e, st) {
      _logger.severe('Error insertDetails', e, st);
      rethrow;
    }
  }

  Future<int> updateTransaction(Map<String, dynamic> tx) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return 0;
      }
      final query = TransactionDao(db);
      final result = await query.updateTransaction(tx);
      return result;
    } catch (e, st) {
      _logger.severe('Error updateTransaction', e, st);
      rethrow;
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return 0;
      }
      final query = TransactionDao(db);
      final result = await query.deleteTransaction(id);
      return result;
    } catch (e, st) {
      _logger.severe('Error deleteTransaction', e, st);
      rethrow;
    }
  }
}
