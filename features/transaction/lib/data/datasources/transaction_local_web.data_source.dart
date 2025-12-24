// Helper LocalDatabase khusus web yang dipisahkan dari TransactionLocalDataSource.
// Helper ini berjalan di web menggunakan `LocalDatabase` (sembast) dan dicampur
// (mixin) ke `TransactionLocalDataSource` agar kode platform-spesifik terpisah.
import 'package:core/core.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:transaction/data/models/transaction_detail.model.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/entitties/transaction_status.extension.dart';

mixin TransactionLocalDataSourceWeb {
  Future<List<TransactionModel>> webGetTransactions(
      {QueryGetTransactions? query}) async {
    final db = LocalDatabase.instance;
    await db.init();
    var rows = await db.getAll(TransactionTable.tableName);
    // normalize id field from '_id' to 'id'
    rows = rows.map((r) {
      final m = Map<String, dynamic>.from(r);
      if (m.containsKey('_id')) {
        m['id'] = m['_id'];
        m.remove('_id');
      }
      return m;
    }).toList();

    // Simple filtering: search and date
    if (query != null) {
      if (query.search != null && query.search!.isNotEmpty) {
        final s = query.search!.toLowerCase();
        rows = rows.where((m) {
          final seq = (m[TransactionTable.colSequenceNumber] ?? '')
              .toString()
              .toLowerCase();
          final notes =
              (m[TransactionTable.colNotes] ?? '').toString().toLowerCase();
          final numberTable = (m[TransactionTable.colNumberTable] ?? '')
              .toString()
              .toLowerCase();
          return seq.contains(s) ||
              notes.contains(s) ||
              numberTable.contains(s);
        }).toList();
      }
      if (query.date != null) {
        final prefix = query.date!.toIso8601String().substring(0, 10);
        rows = rows.where((m) {
          final date = (m[TransactionTable.colDate] ?? '').toString();
          return date.startsWith(prefix);
        }).toList();
      }
    }

    // sort by created_at desc
    rows.sort((a, b) {
      final ad = a[TransactionTable.colCreatedAt] as String?;
      final bd = b[TransactionTable.colCreatedAt] as String?;
      final at = ad != null ? DateTime.tryParse(ad) : null;
      final bt = bd != null ? DateTime.tryParse(bd) : null;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });

    // limit/offset
    if (query != null && (query.limit != null || query.offset != null)) {
      final limit = query.limit ?? rows.length;
      final offset = query.offset ?? 0;
      final end =
          (offset + limit) < rows.length ? (offset + limit) : rows.length;
      rows = rows.sublist(offset, end);
    }

    // attach details
    final result = <TransactionModel>[];
    for (var r in rows) {
      final id = r['id'] as int?;
      List<TransactionDetailModel> details = [];
      if (id != null) {
        details = await webGetDetailsByTransactionId(id);
      }
      final model = TransactionModel.fromDbLocal(r)..copyWith(details: details);
      result.add(model);
    }
    return result;
  }

  Future<List<TransactionDetailModel>> webGetDetailsByTransactionId(
      int txId) async {
    final db = LocalDatabase.instance;
    await db.init();
    final rows = await db.getAll(TransactionDetailTable.tableName);
    final filtered = rows
        .where((r) {
          final m = Map<String, dynamic>.from(r);
          if (m.containsKey('_id')) {
            m['id'] = m['_id'];
            m.remove('_id');
          }
          final v = m[TransactionDetailTable.colTransactionId];
          return v == txId || (v is String && int.tryParse(v) == txId);
        })
        .map((m) => TransactionDetailModel.fromDbLocal((m..remove('_id'))))
        .toList();
    return filtered;
  }

  Future<TransactionModel?> webGetTransactionById(int id) async {
    final txs = await webGetTransactions();
    for (final t in txs) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<TransactionModel?> webGetPendingTransaction() async {
    final txs = await webGetTransactions();
    for (var t in txs) {
      if (t.status != null && t.status!.value == 'pending') return t;
    }
    return null;
  }

  Future<int> webGetLastSequenceNumber() async {
    final db = LocalDatabase.instance;
    await db.init();
    final rows = await db.getAll(TransactionTable.tableName);
    int max = 0;
    for (var r in rows) {
      final m = Map<String, dynamic>.from(r);
      if (m.containsKey('_id')) m['id'] = m['_id'];
      final val = m[TransactionTable.colSequenceNumber];
      final v = val is int ? val : int.tryParse(val?.toString() ?? '0') ?? 0;
      if (v > max) max = v;
    }
    return max;
  }

  Future<TransactionModel?> webInsertTransaction(TransactionModel tx) async {
    final db = LocalDatabase.instance;
    await db.init();
    final map = sanitizeForDb(tx.toInsertDbLocal());
    final key = await db.insert(TransactionTable.tableName, map);
    final created = Map<String, dynamic>.from(map);
    created['id'] = key;
    final model = TransactionModel.fromDbLocal(created);
    return model;
  }

  Future<TransactionModel?> webInsertSyncTransaction(
      TransactionModel tx) async {
    final db = LocalDatabase.instance;
    await db.init();
    final txMap = sanitizeForDb(tx.toInsertDbLocal());
    final txKey = await db.insert(TransactionTable.tableName, txMap);
    final details = tx.details ?? [];
    for (var d in details) {
      final detailMap = sanitizeForDb(d.toInsertDbLocal());
      detailMap[TransactionDetailTable.colTransactionId] = txKey;
      await db.insert(TransactionDetailTable.tableName, detailMap);
    }
    final created = Map<String, dynamic>.from(txMap);
    created['id'] = txKey;
    final createdDetails = await webGetDetailsByTransactionId(txKey);
    return TransactionModel.fromDbLocal(created)
        .copyWith(details: createdDetails);
  }

  Future<List<TransactionDetailModel>?> webInsertDetails(
      List<TransactionDetailModel> details) async {
    final db = LocalDatabase.instance;
    await db.init();
    final inserted = <TransactionDetailModel>[];
    for (var d in details) {
      final map = sanitizeForDb(d.toInsertDbLocal());
      final key = await db.insert(TransactionDetailTable.tableName, map);
      final created = Map<String, dynamic>.from(map);
      created['id'] = key;
      inserted.add(TransactionDetailModel.fromDbLocal(created));
    }
    return inserted;
  }

  Future<List<TransactionDetailModel>?> webReplaceDetailsForTransaction(
      int txId, List<TransactionDetailModel> details) async {
    final db = LocalDatabase.instance;
    await db.init();
    await db.deleteWhereEquals(TransactionDetailTable.tableName,
        TransactionDetailTable.colTransactionId, txId);
    for (var d in details) {
      final map = sanitizeForDb(d.toInsertDbLocal());
      map[TransactionDetailTable.colTransactionId] = txId;
      await db.insert(TransactionDetailTable.tableName, map);
    }
    return await webGetDetailsByTransactionId(txId);
  }

  Future<int> webDeleteDetailsByTransactionId(int txId) async {
    final db = LocalDatabase.instance;
    await db.init();
    return await db.deleteWhereEquals(TransactionDetailTable.tableName,
        TransactionDetailTable.colTransactionId, txId);
  }

  Future<int> webUpdateTransaction(Map<String, dynamic> tx) async {
    final db = LocalDatabase.instance;
    await db.init();
    final id = tx['id'] as int?;
    if (id == null) return 0;
    final map = sanitizeForDb(Map<String, dynamic>.from(tx));
    await db.put(TransactionTable.tableName, id, map);
    return 1;
  }

  Future<int> webDeleteTransaction(int id) async {
    final db = LocalDatabase.instance;
    await db.init();
    // delete details first
    await db.deleteWhereEquals(TransactionDetailTable.tableName,
        TransactionDetailTable.colTransactionId, id);
    // delete transaction record
    final deleted =
        await db.deleteWhereEquals(TransactionTable.tableName, 'id', id);
    return deleted;
  }
}
