import 'package:core/core.dart';
import 'transaction.table.dart';
import 'transaction_detail.table.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/domain/entitties/transaction_status.extension.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';

class TransactionDao {
  final Database database;
  final _logger = Logger('TransactionDao');
  final bool isShowLog = false;

  void _logInfo(String message) {
    if (isShowLog) _logger.info(message);
  }

  // fine logging helper (not used currently)

  void _logSevere(String message, [Object? error, StackTrace? stack]) {
    if (isShowLog) _logger.severe(message, error, stack);
  }

  TransactionDao(this.database);

  Future<List<TransactionModel>> getTransactions(
      {QueryGetTransactions? query}) async {
    try {
      // Build where clause when query provided: match sequence_number or notes, and optional date
      String? where;
      final List<Object?> whereArgs = [];
      if (query != null) {
        final parts = <String>[];
        if (query.search != null && query.search!.isNotEmpty) {
          final like = '%${query.search!.replaceAll('%', r'\%')}%';
          parts.add(
              'CAST(${TransactionTable.colSequenceNumber} AS TEXT) LIKE ? OR ${TransactionTable.colNotes} LIKE ?');
          whereArgs.addAll([like, like]);
        }
        if (query.date != null) {
          // match date prefix (ISO yyyy-MM-dd)
          final prefix = '${query.date!.toIso8601String().substring(0, 10)}%';
          parts.add('${TransactionTable.colDate} LIKE ?');
          whereArgs.add(prefix);
        }
        if (parts.isNotEmpty) {
          where = parts.join(' AND ');
        }
      }

      final txs = await database.query(
        TransactionTable.tableName,
        where: where,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
      );
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

  /// Get the latest pending transaction (status = 'Pending') by `created_at` descending (limit 1) with its details.
  Future<TransactionModel?> getPendingTransaction() async {
    try {
      // Only consider transactions with status = 'Pending' when resolving
      // the "latest" active transaction used by the POS flow.
      final txResult = await database.query(
        TransactionTable.tableName,
        where: '${TransactionTable.colStatus} = ?',
        whereArgs: [TransactionStatus.pending.value],
        orderBy: '${TransactionTable.colCreatedAt} DESC',
        limit: 1,
      );
      if (txResult.isEmpty) return null;

      final row = txResult.first;
      final id = row[TransactionTable.colId] as int?;
      if (id == null) return null;

      final details = await database.query(
        TransactionDetailTable.tableName,
        where: '${TransactionDetailTable.colTransactionId} = ?',
        whereArgs: [id],
      );

      final txModel = TransactionModel.fromDbLocal(row);
      final detailModels =
          details.map((e) => TransactionDetailModel.fromDbLocal(e)).toList();
      _logInfo('getPendingTransaction: success id=$id');
      return txModel.copyWith(details: detailModels);
    } catch (e, s) {
      _logSevere('Error getPendingTransaction: $e', e, s);
      rethrow;
    }
  }

  Future<TransactionModel> insertTransaction(Map<String, dynamic> tx) async {
    try {
      final sw = Stopwatch()..start();
      final result = await database.transaction((txn) async {
        // Pastikan record yang di-insert pertama kali memiliki `synced_at` = NULL
        tx[TransactionTable.colSyncedAt] = null;
        final cleanedTx = Map<String, dynamic>.from(tx)
          ..removeWhere((k, v) => v == null);
        // Ensure status defaults to 'Pending' for newly inserted transactions
        cleanedTx[TransactionTable.colStatus] =
            cleanedTx[TransactionTable.colStatus] ?? 'Pending';
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
      sw.stop();
      if (sw.elapsedMilliseconds > 200) {
        _logInfo(
            'insertTransaction: transaction duration=${sw.elapsedMilliseconds}ms id=${result.id}');
      }
      return result;
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
        // Ensure status defaults to 'Pending' when inserting sync
        cleanedTx[TransactionTable.colStatus] =
            cleanedTx[TransactionTable.colStatus] ?? 'Pending';
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
      // ensure details are removed as well to avoid orphaned rows
      return await database.transaction((txn) async {
        await txn.delete(
          TransactionDetailTable.tableName,
          where: '${TransactionDetailTable.colTransactionId} = ?',
          whereArgs: [id],
        );
        final res = await txn.delete(
          TransactionTable.tableName,
          where: '${TransactionTable.colId} = ?',
          whereArgs: [id],
        );
        _logInfo('deleteTransaction: success id=$id rows=$res');
        return res;
      });
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

  Future<int> clearSyncedAt(int id) async {
    try {
      final res = await database.rawUpdate(
        'UPDATE ${TransactionTable.tableName} SET ${TransactionTable.colSyncedAt} = NULL WHERE ${TransactionTable.colId} = ?',
        [id],
      );
      _logInfo('clearSyncedAt: success id=$id rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error clearSyncedAt: $e', e, s);
      rethrow;
    }
  }

  Future<int> updateTransaction(Map<String, dynamic> tx) async {
    try {
      final id = tx['id'];
      final cleaned = Map<String, dynamic>.from(tx)
        ..removeWhere((k, v) => v == null);
      // remove id from update map if present
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
      final sw = Stopwatch()..start();
      final result = await database.transaction((txn) async {
        if (details.isEmpty) return <TransactionDetailModel>[];

        // All incoming details are assumed to belong to the same transaction id.
        final txId = details.first[TransactionDetailTable.colTransactionId];

        // Prefetch existing details for this transaction in one query to avoid
        // per-item SELECTs which prolong transaction time and increase lock risk.
        final existingRows = await txn.query(
          TransactionDetailTable.tableName,
          where: '${TransactionDetailTable.colTransactionId} = ?',
          whereArgs: [txId],
        );

        // Build lookup maps for quick existing-row detection by packet_id or product_id
        final Map<int, Map<String, Object?>> byPacket = {};
        final Map<int, Map<String, Object?>> byProduct = {};
        for (var r in existingRows) {
          final packet = r[TransactionDetailTable.colPacketId] as int?;
          final prod = r[TransactionDetailTable.colProductId] as int?;
          final id = r[TransactionDetailTable.colId] as int?;
          if (packet != null && id != null) byPacket[packet] = r;
          if (prod != null && id != null) byProduct[prod] = r;
        }

        final batch = txn.batch();

        // Prepare batch operations (updates or inserts)
        for (var d in details) {
          final prodId = d[TransactionDetailTable.colProductId];
          final packetId = d[TransactionDetailTable.colPacketId];

          Map<String, Object?>? existing;
          if (packetId != null) {
            existing = byPacket[packetId];
          } else if (prodId != null) {
            existing = byProduct[prodId as int];
          }

          if (existing != null) {
            // update existing: sum qty and recompute subtotal
            final existingModel = TransactionDetailModel.fromDbLocal(existing);
            final existingQty = existingModel.qty ?? 0;
            final incomingQty = (d[TransactionDetailTable.colQty] as int?) ?? 0;
            final price = (packetId != null
                    ? (d[TransactionDetailTable.colPacketPrice] as int?)
                    : (d[TransactionDetailTable.colProductPrice] as int?)) ??
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
            if (d.containsKey(TransactionDetailTable.colNote) &&
                d[TransactionDetailTable.colNote] != null) {
              updateMap[TransactionDetailTable.colNote] =
                  d[TransactionDetailTable.colNote];
            }

            batch.update(
              TransactionDetailTable.tableName,
              updateMap,
              where: '${TransactionDetailTable.colId} = ?',
              whereArgs: [existing[TransactionDetailTable.colId]],
            );
          } else {
            final cleaned = Map<String, dynamic>.from(d)
              ..removeWhere((k, v) => v == null);
            batch.insert(TransactionDetailTable.tableName, cleaned);
          }
        }

        // Commit batch; using noResult: true reduces memory for result payload
        await batch.commit(noResult: true);

        // Re-query final rows for this transaction and return models.
        final finalRows = await txn.query(
          TransactionDetailTable.tableName,
          where: '${TransactionDetailTable.colTransactionId} = ?',
          whereArgs: [txId],
        );
        final inserted = finalRows
            .map((e) => TransactionDetailModel.fromDbLocal(e))
            .toList();
        _logInfo('insertDetails: success count=${inserted.length}');
        return inserted;
      });
      sw.stop();
      if (sw.elapsedMilliseconds > 200) {
        _logInfo(
            'insertDetails: transaction duration=${sw.elapsedMilliseconds}ms rows=${result.length}');
      }
      return result;
    } catch (e, s) {
      _logSevere('Error insertDetails: $e', e, s);
      rethrow;
    }
  }

  /// Sanitize a map for DB insertion/updating.
  /// Mirrors the logic in TransactionLocalDataSource._sanitizeForDb to keep behavior consistent.

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
