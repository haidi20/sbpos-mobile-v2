import 'transaction.table.dart';
import 'transaction_detail.table.dart';
import 'package:core/core.dart';
import 'package:transaction/data/models/transaction_model.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';

class TransactionDao {
  final Database database;
  final _logger = Logger('TransactionDao');

  TransactionDao(this.database);

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final txs = await database.query(TransactionTable.tableName);
      List<TransactionModel> result = [];
      for (var t in txs) {
        final details = await database.query(
          TransactionDetailTable.tableName,
          where: '${TransactionDetailTable.colTransactionId} = ?',
          whereArgs: [t[TransactionTable.colId]],
        );
        final txModel = TransactionModel.fromDbLocal(t);
        final detailModels =
            details.map((e) => TransactionDetailModel.fromDbLocal(e)).toList();
        result.add(txModel.copyWith(details: detailModels));
      }
      return result;
    } catch (e, s) {
      _logger.severe('Error getTransactions: $e', e, s);
      rethrow;
    }
  }

  Future<TransactionModel> insertTransaction(Map<String, dynamic> tx) async {
    try {
      return await database.transaction((txn) async {
        final id = await txn.insert(TransactionTable.tableName, tx);
        final inserted = await txn.query(
          TransactionTable.tableName,
          where: '${TransactionTable.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );
        // return model without details (caller can insert details separately)
        return TransactionModel.fromDbLocal(inserted.first);
      });
    } catch (e, s) {
      _logger.severe('Error insertTransaction: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      return await database.delete(
        TransactionTable.tableName,
        where: '${TransactionTable.colId} = ?',
        whereArgs: [id],
      );
    } catch (e, s) {
      _logger.severe('Error deleteTransaction: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearTransactions() async {
    try {
      return await database.delete(TransactionTable.tableName);
    } catch (e, s) {
      _logger.severe('Error clearTransactions: $e', e, s);
      rethrow;
    }
  }

  // Detail operations
  Future<List<TransactionDetailModel>> getDetailsByTransactionId(
      int txId) async {
    try {
      final results = await database.query(
        TransactionDetailTable.tableName,
        where: '${TransactionDetailTable.colTransactionId} = ?',
        whereArgs: [txId],
      );
      return results.map((e) => TransactionDetailModel.fromDbLocal(e)).toList();
    } catch (e, s) {
      _logger.severe('Error getDetailsByTransactionId: $e', e, s);
      rethrow;
    }
  }

  Future<List<TransactionDetailModel>> insertDetails(
      List<Map<String, dynamic>> details) async {
    try {
      return await database.transaction((txn) async {
        List<TransactionDetailModel> inserted = [];
        for (var d in details) {
          final id = await txn.insert(TransactionDetailTable.tableName, d);
          final result = await txn.query(
            TransactionDetailTable.tableName,
            where: '${TransactionDetailTable.colId} = ?',
            whereArgs: [id],
            limit: 1,
          );
          inserted.add(TransactionDetailModel.fromDbLocal(result.first));
        }
        return inserted;
      });
    } catch (e, s) {
      _logger.severe('Error insertDetails: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteDetailsByTransactionId(int txId) async {
    try {
      return await database.delete(
        TransactionDetailTable.tableName,
        where: '${TransactionDetailTable.colTransactionId} = ?',
        whereArgs: [txId],
      );
    } catch (e, s) {
      _logger.severe('Error deleteDetailsByTransactionId: $e', e, s);
      rethrow;
    }
  }
}
