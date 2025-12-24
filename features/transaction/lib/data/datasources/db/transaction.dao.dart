import 'package:core/core.dart';
import 'transaction.table.dart';
import 'transaction_detail.table.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/domain/entitties/transaction_status.extension.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:customer/data/datasources/db/customer.table.dart';
import 'package:product/data/datasources/db/product.table.dart';

/// DAO untuk operasi data transaksi pada database lokal (SQLite).
/// Menyediakan fungsi membaca, menulis, dan memperbarui transaksi
/// beserta detailnya dengan pendekatan yang aman dan efisien.
class TransactionDao {
  final Database? database;
  final _logger = Logger('TransactionDao');
  final bool isShowLog = false;

  void _logInfo(String message) {
    if (isShowLog) _logger.info(message);
  }

  // helper logging tambahan (tidak digunakan saat ini)

  void _logSevere(String message, [Object? error, StackTrace? stack]) {
    if (isShowLog) _logger.severe(message, error, stack);
  }

  TransactionDao(this.database);

  Database _ensureDb() {
    if (database == null) {
      throw UnsupportedError(
          'TransactionDao: database is null (web). Use web data source implementations.');
    }
    return database!;
  }

  /// Mengambil daftar transaksi beserta detailnya.
  ///
  /// Pencarian mendukung kata kunci pada: nomor urut (sequence), catatan,
  /// nomor meja, nama pelanggan, nama produk, dan `product_name` di detail.
  /// Dapat difilter berdasarkan tanggal (prefix `YYYY-MM-DD`).
  Future<List<TransactionModel>> getTransactions(
      {QueryGetTransactions? query}) async {
    try {
      // Susun SQL dengan LEFT JOIN ke customers, transaction_details, dan
      // products untuk mendukung pencarian berdasarkan nama pelanggan dan produk.
      // Gunakan DISTINCT agar baris transaksi tidak terduplikasi akibat hasil JOIN.
      // COLLATE NOCASE untuk pencarian case-insensitive pada kolom teks.
      final List<Object?> whereArgs = [];
      final parts = <String>[];
      if (query != null) {
        if (query.search != null && query.search!.isNotEmpty) {
          final like = '%${query.search!.replaceAll('%', r'\%')}%';
          parts.add('('
              'CAST(t.${TransactionTable.colSequenceNumber} AS TEXT) LIKE ? OR '
              't.${TransactionTable.colNotes} LIKE ? COLLATE NOCASE OR '
              'CAST(t.${TransactionTable.colNumberTable} AS TEXT) LIKE ? OR '
              'c.${CustomerTable.colName} LIKE ? COLLATE NOCASE OR '
              'p.${ProductTable.colName} LIKE ? COLLATE NOCASE OR '
              'td.${TransactionDetailTable.colProductName} LIKE ? COLLATE NOCASE'
              ')');
          whereArgs.addAll([like, like, like, like, like, like]);
        }
        if (query.date != null) {
          final prefix = '${query.date!.toIso8601String().substring(0, 10)}%';
          parts.add('t.${TransactionTable.colDate} LIKE ?');
          whereArgs.add(prefix);
        }
      }

      final whereClause =
          parts.isNotEmpty ? 'WHERE ${parts.join(' AND ')}' : '';
      var sql = 'SELECT DISTINCT t.* FROM ${TransactionTable.tableName} t '
          'LEFT JOIN ${CustomerTable.tableName} c ON c.${CustomerTable.colId} = t.${TransactionTable.colCustomerId} '
          'LEFT JOIN ${TransactionDetailTable.tableName} td ON td.${TransactionDetailTable.colTransactionId} = t.${TransactionTable.colId} '
          'LEFT JOIN ${ProductTable.tableName} p ON p.${ProductTable.colId} = td.${TransactionDetailTable.colProductId} '
          '$whereClause '
          'ORDER BY t.${TransactionTable.colCreatedAt} DESC';

      // Tambahkan LIMIT/OFFSET jika disediakan.
      if (query != null) {
        if (query.limit != null && query.offset != null) {
          sql = '$sql LIMIT ? OFFSET ?';
          whereArgs.addAll([query.limit, query.offset]);
        } else if (query.limit != null) {
          sql = '$sql LIMIT ?';
          whereArgs.add(query.limit);
        } else if (query.offset != null) {
          // SQLite memerlukan LIMIT jika menggunakan OFFSET; gunakan LIMIT -1.
          sql = '$sql LIMIT -1 OFFSET ?';
          whereArgs.add(query.offset);
        }
      }

      final txs = await _ensureDb().rawQuery(sql, whereArgs);
      List<TransactionModel> result = [];
      for (var t in txs) {
        final details = await _ensureDb().query(
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

  /// Mengambil satu transaksi berdasarkan `id` (termasuk detailnya).
  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      final txResult = await _ensureDb().query(
        TransactionTable.tableName,
        where: '${TransactionTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (txResult.isEmpty) return null;

      final details = await _ensureDb().query(
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

  /// Mengambil transaksi Pending terbaru (status = 'Pending') berdasarkan
  /// `created_at` menurun (limit 1), termasuk detailnya.
  Future<TransactionModel?> getPendingTransaction() async {
    try {
      // Hanya mempertimbangkan transaksi dengan status = 'Pending' saat
      // menentukan transaksi aktif terbaru yang dipakai alur POS.
      final txResult = await _ensureDb().query(
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

      final details = await _ensureDb().query(
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

  /// Menyisipkan transaksi baru ke tabel `transactions`.
  /// Nilai `synced_at` diset NULL, status default 'Pending'.
  /// Mengembalikan model transaksi tanpa detail (detail disimpan terpisah).
  Future<TransactionModel> insertTransaction(Map<String, dynamic> tx) async {
    try {
      final sw = Stopwatch()..start();
      final result = await _ensureDb().transaction((txn) async {
        // Pastikan record awal memiliki `synced_at` = NULL
        tx[TransactionTable.colSyncedAt] = null;
        final cleanedTx = Map<String, dynamic>.from(tx)
          ..removeWhere((k, v) => v == null);
        // Pastikan status default 'Pending' untuk transaksi baru
        cleanedTx[TransactionTable.colStatus] =
            cleanedTx[TransactionTable.colStatus] ?? 'Pending';
        final id = await txn.insert(TransactionTable.tableName, cleanedTx);
        final inserted = await txn.query(
          TransactionTable.tableName,
          where: '${TransactionTable.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );
        // kembalikan model tanpa detail (pemanggil menyimpan detail terpisah)
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

  /// Menyisipkan transaksi beserta detailnya dalam satu transaksi DB.
  /// `tx` adalah map untuk tabel transactions, `details` adalah list map untuk transaction_details.
  Future<TransactionModel> insertSyncTransaction(
      Map<String, dynamic> tx, List<Map<String, dynamic>> details) async {
    try {
      return await _ensureDb().transaction((txn) async {
        final cleanedTx = Map<String, dynamic>.from(tx)
          ..removeWhere((k, v) => v == null);
        // Pastikan status default 'Pending' saat insert sinkronisasi
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

  /// Menghapus transaksi beserta seluruh detailnya berdasarkan `id`.
  Future<int> deleteTransaction(int id) async {
    try {
      // pastikan detail ikut terhapus agar tidak ada baris yatim
      return await _ensureDb().transaction((txn) async {
        await txn.delete(
          TransactionDetailTable.tableName,
          where: '${TransactionDetailTable.colTransactionId} = ?',
          whereArgs: [id],
        );
        final res = await _ensureDb().delete(
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

  /// Menghapus seluruh baris pada tabel `transactions` (tidak menyentuh detail).
  Future<int> clearTransactions() async {
    try {
      final res = await _ensureDb().delete(TransactionTable.tableName);
      _logInfo('clearTransactions: success rows=$res');
      return res;
    } catch (e, s) {
      _logSevere('Error clearTransactions: $e', e, s);
      rethrow;
    }
  }

  /// Mengosongkan kolom `synced_at` pada transaksi tertentu.
  Future<int> clearSyncedAt(int id) async {
    try {
      final res = await _ensureDb().rawUpdate(
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

  /// Memperbarui satu transaksi berdasarkan `id` di dalam map.
  /// `id` akan dihapus dari payload update (hanya untuk klausa WHERE).
  Future<int> updateTransaction(Map<String, dynamic> tx) async {
    try {
      final id = tx['id'];
      final cleaned = Map<String, dynamic>.from(tx)
        ..removeWhere((k, v) => v == null);
      // hapus `id` dari map update jika ada
      cleaned.remove('id');
      final res = await _ensureDb().update(
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

  /// Mengembalikan nomor urut (sequence_number) tertinggi pada tabel `transactions`.
  /// Jika tidak ada, kembalikan 0.
  Future<int> getLastSequenceNumber() async {
    try {
      final rows = await _ensureDb().rawQuery(
        'SELECT MAX(${TransactionTable.colSequenceNumber}) as max_seq FROM ${TransactionTable.tableName}',
      );
      if (rows.isEmpty) return 0;
      final first = rows.first;
      final val = first['max_seq'];
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    } catch (e, s) {
      _logSevere('Error getLastSequenceNumber: $e', e, s);
      rethrow;
    }
  }

  // Operasi detail
  /// Mengambil list detail transaksi berdasarkan `transaction_id`.
  Future<List<TransactionDetailModel>> getDetailsByTransactionId(
      int txId) async {
    try {
      final results = await _ensureDb().query(
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

  /// Menambahkan atau memperbarui detail transaksi secara batch.
  /// Jika item (berdasarkan `packet_id` atau `product_id`) sudah ada, qty dijumlah
  /// dan subtotal dihitung ulang; jika belum ada, akan di-insert.
  Future<List<TransactionDetailModel>> insertDetails(
      List<Map<String, dynamic>> details) async {
    try {
      final sw = Stopwatch()..start();
      final result = await _ensureDb().transaction((txn) async {
        if (details.isEmpty) return <TransactionDetailModel>[];

        // Diasumsikan semua detail masuk untuk transaction_id yang sama.
        final txId = details.first[TransactionDetailTable.colTransactionId];

        // Ambil detail yang sudah ada dalam satu query untuk menghindari SELECT
        // per-item yang memperlama transaksi dan meningkatkan risiko lock.
        final existingRows = await txn.query(
          TransactionDetailTable.tableName,
          where: '${TransactionDetailTable.colTransactionId} = ?',
          whereArgs: [txId],
        );

        // Bangun map lookup untuk mendeteksi baris existing via packet_id atau product_id
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

        // Siapkan operasi batch (update atau insert)
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
            // update existing: jumlahkan qty dan hitung ulang subtotal
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

        // Commit batch; penggunaan noResult: true mengurangi beban memori
        await batch.commit(noResult: true);

        // Query ulang baris final untuk transaksi ini dan kembalikan sebagai model.
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

  /// Mengganti seluruh detail untuk sebuah transaksi secara atomik:
  /// DELETE baris lama lalu INSERT baris baru.
  Future<List<TransactionDetailModel>> replaceDetailsForTransaction(
      int txId, List<Map<String, dynamic>> details) async {
    try {
      final result = await _ensureDb().transaction((txn) async {
        // Hapus baris existing untuk transaction_id ini
        await txn.delete(
          TransactionDetailTable.tableName,
          where: '${TransactionDetailTable.colTransactionId} = ?',
          whereArgs: [txId],
        );

        // Insert baris baru secara batch untuk efisiensi
        final batch = txn.batch();
        for (var d in details) {
          final map = Map<String, dynamic>.from(d)
            ..removeWhere((k, v) => v == null);
          map[TransactionDetailTable.colTransactionId] = txId;
          batch.insert(TransactionDetailTable.tableName, map,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);

        // Kembalikan set baris final
        final finalRows = await txn.query(
          TransactionDetailTable.tableName,
          where: '${TransactionDetailTable.colTransactionId} = ?',
          whereArgs: [txId],
        );
        return finalRows
            .map((e) => TransactionDetailModel.fromDbLocal(e))
            .toList();
      });
      _logInfo(
          'replaceDetailsForTransaction: success txId=$txId count=${result.length}');
      return result;
    } catch (e, s) {
      _logSevere('Error replaceDetailsForTransaction: $e', e, s);
      rethrow;
    }
  }

  /// Sanitasi map untuk operasi insert/update DB (catatan internal).
  /// Mencerminkan logika di `TransactionLocalDataSource._sanitizeForDb` agar konsisten.

  /// Menghapus semua detail berdasarkan `transaction_id`.
  Future<int> deleteDetailsByTransactionId(int txId) async {
    try {
      final res = await _ensureDb().delete(
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
