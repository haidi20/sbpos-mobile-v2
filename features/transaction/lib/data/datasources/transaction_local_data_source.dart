import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';
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
