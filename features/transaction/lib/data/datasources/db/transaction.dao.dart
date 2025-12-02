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

  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      final txResult = await database.query(
        TransactionTable.tableName,
        where: '${TransactionTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (txResult.isEmpty) return null;

      final details = await database.query(
        TransactionDetailTable.tableName,
        where: '${TransactionDetailTable.colTransactionId} = ?',
        whereArgs: [id],
      );
      final txModel = TransactionModel.fromDbLocal(txResult.first);
      final detailModels =
          details.map((e) => TransactionDetailModel.fromDbLocal(e)).toList();
      return txModel.copyWith(details: detailModels);
    } catch (e, s) {
      _logger.severe('Error getTransactionById: $e', e, s);
      rethrow;
    }
  }

  Future<TransactionModel> insertTransaction(Map<String, dynamic> tx) async {
    try {
      return await database.transaction((txn) async {
        // Pastikan record yang di-insert pertama kali memiliki `synced_at` = NULL
        tx[TransactionTable.colSyncedAt] = null;
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

  /// Insert transaction beserta detailnya dalam satu transaksi DB.
  /// `tx` adalah map untuk table transactions, `details` adalah list map untuk transaction_details.
  Future<TransactionModel> insertSyncTransaction(
      Map<String, dynamic> tx, List<Map<String, dynamic>> details) async {
    try {
      return await database.transaction((txn) async {
        final id = await txn.insert(TransactionTable.tableName, tx);

        List<TransactionDetailModel> insertedDetails = [];
        for (var d in details) {
          // pastikan transaction_id terisi
          d[TransactionDetailTable.colTransactionId] = id;
          final detailId =
              await txn.insert(TransactionDetailTable.tableName, d);
          final result = await txn.query(
            TransactionDetailTable.tableName,
            where: '${TransactionDetailTable.colId} = ?',
            whereArgs: [detailId],
            limit: 1,
          );
          if (result.isNotEmpty) {
            insertedDetails
                .add(TransactionDetailModel.fromDbLocal(result.first));
          }
        }

        final txResult = await txn.query(
          TransactionTable.tableName,
          where: '${TransactionTable.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );

        return TransactionModel.fromDbLocal(txResult.first)
            .copyWith(details: insertedDetails);
      });
    } catch (e, s) {
      _logger.severe('Error insertSyncTransaction: $e', e, s);
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

  Future<int> updateTransaction(Map<String, dynamic> tx) async {
    try {
      return await database.update(
        TransactionTable.tableName,
        tx,
        where: '${TransactionTable.colId} = ?',
        whereArgs: [tx['id']],
      );
    } catch (e, s) {
      _logger.severe('Error updateTransaction: $e', e, s);
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
