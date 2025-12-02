import 'transaction.table.dart';
import 'transaction_detail.table.dart';
import 'package:core/core.dart';
import 'package:transaction/data/models/transaction_model.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';

class TransactionDao {
  final Database database;
  final _logger = Logger('TransactionDao');
  final bool isShowLog = false;

  void _logInfo(String message) {
    if (isShowLog) _logger.info(message);
  }

  void _logSevere(String message, [Object? error, StackTrace? stack]) {
    if (isShowLog) _logger.severe(message, error, stack);
  }

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
      _logInfo('getTransactions: success count=${result.length}');
      return result;
    } catch (e, s) {
      _logSevere('Error getTransactions: $e', e, s);
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
      _logInfo('getTransactionById: success id=$id');
      return txModel.copyWith(details: detailModels);
    } catch (e, s) {
      _logSevere('Error getTransactionById: $e', e, s);
      rethrow;
    }
  }

  Future<TransactionModel> insertTransaction(Map<String, dynamic> tx) async {
    try {
      return await database.transaction((txn) async {
        // Pastikan record yang di-insert pertama kali memiliki `synced_at` = NULL
        tx[TransactionTable.colSyncedAt] = null;
        final cleanedTx = Map<String, dynamic>.from(tx)
          ..removeWhere((k, v) => v == null);
        final id = await txn.insert(TransactionTable.tableName, cleanedTx);
        final inserted = await txn.query(
          TransactionTable.tableName,
          where: '${TransactionTable.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );
        // return model without details (caller can insert details separately)
        final model = TransactionModel.fromDbLocal(inserted.first);
        _logInfo('insertTransaction: success id=${model.id}');
        return model;
      });
    } catch (e, s) {
      _logSevere('Error insertTransaction: $e', e, s);
      rethrow;
    }
  }

  /// Insert transaction beserta detailnya dalam satu transaksi DB.
  /// `tx` adalah map untuk table transactions, `details` adalah list map untuk transaction_details.
  Future<TransactionModel> insertSyncTransaction(
      Map<String, dynamic> tx, List<Map<String, dynamic>> details) async {
    try {
      return await database.transaction((txn) async {
        final cleanedTx = Map<String, dynamic>.from(tx)
          ..removeWhere((k, v) => v == null);
        final id = await txn.insert(TransactionTable.tableName, cleanedTx);

        List<TransactionDetailModel> insertedDetails = [];
        for (var d in details) {
          // pastikan transaction_id terisi
          d[TransactionDetailTable.colTransactionId] = id;
          final cleanedDetail = Map<String, dynamic>.from(d)
            ..removeWhere((k, v) => v == null);
          final detailId =
              await txn.insert(TransactionDetailTable.tableName, cleanedDetail);
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

        final model = TransactionModel.fromDbLocal(txResult.first)
            .copyWith(details: insertedDetails);
        _logInfo(
            'insertSyncTransaction: success id=${model.id} details=${insertedDetails.length}');
        return model;
      });
    } catch (e, s) {
      _logSevere('Error insertSyncTransaction: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      final res = await database.delete(
        TransactionTable.tableName,
        where: '${TransactionTable.colId} = ?',
        whereArgs: [id],
      );
      _logInfo('deleteTransaction: success id=$id rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error deleteTransaction: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearTransactions() async {
    try {
      final res = await database.delete(TransactionTable.tableName);
      _logInfo('clearTransactions: success rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error clearTransactions: $e', e, s);
      rethrow;
    }
  }

  Future<int> updateTransaction(Map<String, dynamic> tx) async {
    try {
      final id = tx['id'];
      final cleaned = Map<String, dynamic>.from(tx)
        ..removeWhere((k, v) => v == null);
      // remove id from update map
      cleaned.remove('id');
      final res = await database.update(
        TransactionTable.tableName,
        cleaned,
        where: '${TransactionTable.colId} = ?',
        whereArgs: [id],
      );
      _logInfo('updateTransaction: success id=$id rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error updateTransaction: $e', e, s);
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
      final list =
          results.map((e) => TransactionDetailModel.fromDbLocal(e)).toList();
      _logInfo(
          'getDetailsByTransactionId: success txId=$txId count=${list.length}');
      return list;
    } catch (e, s) {
      _logSevere('Error getDetailsByTransactionId: $e', e, s);
      rethrow;
    }
  }

  Future<List<TransactionDetailModel>> insertDetails(
      List<Map<String, dynamic>> details) async {
    try {
      return await database.transaction((txn) async {
        List<TransactionDetailModel> inserted = [];
        for (var d in details) {
          final txId = d[TransactionDetailTable.colTransactionId];
          final prodId = d[TransactionDetailTable.colProductId];

          // check existing detail by transaction_id + product_id
          final existing = await txn.query(
            TransactionDetailTable.tableName,
            where:
                '${TransactionDetailTable.colTransactionId} = ? AND ${TransactionDetailTable.colProductId} = ?',
            whereArgs: [txId, prodId],
            limit: 1,
          );

          if (existing.isNotEmpty) {
            // update existing: sum qty and recompute subtotal
            final existingModel =
                TransactionDetailModel.fromDbLocal(existing.first);
            final existingQty = existingModel.qty ?? 0;
            final incomingQty = (d[TransactionDetailTable.colQty] as int?) ?? 0;
            final price = (d[TransactionDetailTable.colProductPrice] as int?) ??
                existingModel.productPrice ??
                0;
            final newQty = existingQty + incomingQty;
            final newSubtotal = price * newQty;

            final updateMap = {
              TransactionDetailTable.colQty: newQty,
              TransactionDetailTable.colSubtotal: newSubtotal,
              TransactionDetailTable.colUpdatedAt:
                  DateTime.now().toIso8601String(),
            };
            await txn.update(
              TransactionDetailTable.tableName,
              updateMap,
              where: '${TransactionDetailTable.colId} = ?',
              whereArgs: [existingModel.id],
            );

            final updatedRow = await txn.query(
              TransactionDetailTable.tableName,
              where: '${TransactionDetailTable.colId} = ?',
              whereArgs: [existingModel.id],
              limit: 1,
            );
            inserted.add(TransactionDetailModel.fromDbLocal(updatedRow.first));
          } else {
            final cleaned = Map<String, dynamic>.from(d)
              ..removeWhere((k, v) => v == null);
            final id =
                await txn.insert(TransactionDetailTable.tableName, cleaned);
            final result = await txn.query(
              TransactionDetailTable.tableName,
              where: '${TransactionDetailTable.colId} = ?',
              whereArgs: [id],
              limit: 1,
            );
            inserted.add(TransactionDetailModel.fromDbLocal(result.first));
          }
        }
        _logInfo('insertDetails: success count=${inserted.length}');
        return inserted;
      });
    } catch (e, s) {
      _logSevere('Error insertDetails: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteDetailsByTransactionId(int txId) async {
    try {
      final res = await database.delete(
        TransactionDetailTable.tableName,
        where: '${TransactionDetailTable.colTransactionId} = ?',
        whereArgs: [txId],
      );
      _logInfo('deleteDetailsByTransactionId: success txId=$txId rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error deleteDetailsByTransactionId: $e', e, s);
      rethrow;
    }
  }
}
