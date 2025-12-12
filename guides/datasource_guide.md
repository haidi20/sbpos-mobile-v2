**Panduan Datasource (Transaction)**

Tujuan: panduan ini menyediakan template file dan contoh kode untuk struktur datasource fitur `transaction`. Salin template ke file yang sesuai dan sesuaikan model/DAO/repository Anda.

Struktur yang didokumentasikan:

datasources
├── db
│   ├── transaction.dao.dart
│   └── transaction.table.dart
├── transaction_local.data_source.dart
└── transaction_remote.data_source.dart

Catatan umum:
- Gunakan `TransactionModel` untuk mapping JSON/DB.
- DAO (`transaction.dao.dart`) adalah kontrak untuk operasi DB lokal.
- `transaction.table.dart` menyimpan nama tabel, kolom, SQL create statements, serta fungsi dari/ke `Map<String, dynamic>`.
- `transaction_local.data_source.dart` memanggil `TransactionDao` dan mengekspor fungsi helper.
- `transaction_remote.data_source.dart` berisi panggilan API (response parsing) dan kelas response sederhana.

1) db/transaction.dao.dart

Contoh (kelas konkret — tidak perlu abstrak):

```dart
import 'package:core/core.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';

class TransactionDao {
  final Database database;
  final _logger = Logger('TransactionDao');
  final bool isShowLog = false;

  TransactionDao(this.database);

  Future<List<TransactionModel>> getTransactions({int? limit, int? offset}) async {
    final rows = await database.query(
      TransactionTable.tableName,
      limit: limit,
      offset: offset,
    );
    return rows.map((r) => TransactionModel.fromDbLocal(r)).toList();
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final rows = await database.query(
      TransactionTable.tableName,
      where: '${TransactionTable.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TransactionModel.fromDbLocal(rows.first);
  }

  Future<TransactionModel> insertTransaction(Map<String, dynamic> data) async {
    return await database.transaction((txn) async {
      final id = await txn.insert(TransactionTable.tableName, data);
      final inserted = await txn.query(
        TransactionTable.tableName,
        where: '${TransactionTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      return TransactionModel.fromDbLocal(inserted.first);
    });
  }

  Future<int> updateTransaction(Map<String, dynamic> map) async {
    final id = map['id'];
    final cleaned = Map<String, dynamic>.from(map)..remove('id');
    return await database.update(
      TransactionTable.tableName,
      cleaned,
      where: '${TransactionTable.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    return await database.delete(
      TransactionTable.tableName,
      where: '${TransactionTable.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearSyncedAt(int id) async {
    return await database.rawUpdate(
      'UPDATE ${TransactionTable.tableName} SET ${TransactionTable.colSyncedAt} = NULL WHERE ${TransactionTable.colId} = ?',
      [id],
    );
  }
}
```

2) db/transaction.table.dart

Contoh format tabel yang konsisten (meniru `CustomerTable` style):

```dart
class TransactionTable {
  static const String tableName = 'transactions';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colTotal = 'total';
  static const String colCreatedAt = 'created_at';
  static const String colSyncedAt = 'synced_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER,
      $colTotal REAL,
      $colCreatedAt TEXT NULL,
      $colSyncedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colDeletedAt TEXT NULL
    )
  ''';
}
```

3) transaction_local.data_source.dart

4) transaction_local.data_source.dart

Contoh sesuai pola `CustomerLocalDataSource` (sesuaikan nama paket & model):

```dart
import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/datasources/db/transaction.dao.dart';

class TransactionLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final Database? _testDb;
  final _logger = Logger('TransactionLocalDataSource');
  final bool isShowLog = false;

  TransactionLocalDataSource({Database? testDb}) : _testDb = testDb;

  void _logInfo(String msg) {
    if (isShowLog) _logger.info(msg);
  }

  void _logWarning(String msg) {
    if (isShowLog) _logger.warning(msg);
  }

  void _logSevere(String msg, [Object? e, StackTrace? st]) {
    if (isShowLog) _logger.severe(msg, e, st);
  }

  Future<T> _withRetry<T>(Future<T> Function() action,
      {int retries = 3,
      Duration delay = const Duration(milliseconds: 50)}) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (_) {
        attempt++;
        if (attempt >= retries) rethrow;
        await Future.delayed(delay);
      }
    }
  }

  @visibleForTesting
  TransactionDao createDao(Database db) => TransactionDao(db);

  Future<List<TransactionModel>> getTransactions({int? limit, int? offset}) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat getTransactions');
        return [];
      }
      final dao = createDao(db);
      final result = await dao.getTransactions(limit: limit, offset: offset);
      _logInfo('getTransactions: count=${result.length}');
      return result;
    } catch (e, st) {
      _logSevere('Error getTransactions', e, st);
      rethrow;
    }
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat getTransactionById');
        return null;
      }
      final dao = createDao(db);
      return await dao.getTransactionById(id);
    } catch (e, st) {
      _logSevere('Error getTransactionById', e, st);
      rethrow;
    }
  }

  Future<TransactionModel?> insertTransaction(TransactionModel txn) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat insertTransaction');
        return null;
      }
      final dao = createDao(db);
      final map = sanitizeForDb(txn.toInsertDbLocal());
      final inserted =
          await _withRetry(() async => await dao.insertTransaction(map));
      _logInfo('insertTransaction: id=${inserted.id}');
      return inserted;
    } catch (e, st) {
      _logSevere('Error insertTransaction', e, st);
      rethrow;
    }
  }

  Future<int> updateTransaction(Map<String, dynamic> data) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat updateTransaction');
        return 0;
      }
      final dao = createDao(db);
      final map = sanitizeForDb(Map<String, dynamic>.from(data));
      if (data.containsKey('id')) map['id'] = data['id'];
      final updated = await dao.updateTransaction(map);
      _logInfo('updateTransaction: rows=$updated');
      return updated;
    } catch (e, st) {
      _logSevere('Error updateTransaction', e, st);
      rethrow;
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat deleteTransaction');
        return 0;
      }
      final dao = createDao(db);
      final count = await dao.deleteTransaction(id);
      _logInfo('deleteTransaction: rows=$count');
      return count;
    } catch (e, st) {
      _logSevere('Error deleteTransaction', e, st);
      rethrow;
    }
  }

  Future<int> clearTransactions() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat clearTransactions');
        return 0;
      }
      final dao = createDao(db);
      return await dao.clearTransactions();
    } catch (e, st) {
      _logSevere('Error clearTransactions', e, st);
      rethrow;
    }
  }

  Future<int> clearSyncedAt(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat clearSyncedAt');
        return 0;
      }
      final dao = createDao(db);
      final count = await dao.clearSyncedAt(id);
      _logInfo('clearSyncedAt: rows=$count');
      return count;
    } catch (e, st) {
      _logSevere('Error clearSyncedAt', e, st);
      rethrow;
    }
  }
}
```

5) transaction_remote.data_source.dart

Contoh minimal (sesuaikan klien HTTP yang dipakai):

```dart
// Response wrapper for transaction
import 'package:core/core.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/responses/transaction.response.dart';

class TransactionRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  TransactionRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<TransactionResponse> fetchTransactions({Map<String, dynamic>? params}) async {
    final response = await handleApiResponse(
      () async =>
          _apiHelper.get(url: '$host/$api/transactions', params: params ?? {}),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  /// Kirim transaksi ke API remote. Mengembalikan respons ter-decode.
  Future<TransactionResponse> postTransaction(Map<String, dynamic> payload) async {
    final response = await handleApiResponse(
      () async =>
          _apiHelper.post(url: '$host/$api/transactions', body: payload),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  Future<TransactionResponse> getTransaction(int id) async {
    final response = await handleApiResponse(
      () async => _apiHelper.get(url: '$host/$api/transactions/$id'),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  Future<TransactionResponse> updateTransaction(int id, Map<String, dynamic> payload) async {
    final response = await handleApiResponse(
      () async => _apiHelper.put(url: '$host/$api/transactions/$id', body: payload),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  Future<TransactionResponse> deleteTransaction(int id) async {
    final response = await handleApiResponse(
      () async => _apiHelper.delete(url: '$host/$api/transactions/$id'),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  // _writeResponseToFile removed — tidak digunakan
}
```

Panduan penggunaan singkat:
- Letakkan file-file di path yang dinyatakan.
- Buat implementasi `TransactionDao` di layer `data/datasources/db/` yang menggunakan sqlite/sqflite.
- Override provider datasource/repository di composition root (`main.dart`) agar provider di `presentation/providers` dapat membaca instance nyata.
- Pastikan model (`TransactionModel`) punya `fromJson`, `toJson`, `toInsertDbLocal()` dan `fromDbLocal()` bila diperlukan.

Lokasi file response (filesystem):

- Buat file response untuk transaksi pada path absolut berikut:

  D:\projects\sbpos_mobile_v2\features\transaction\lib\data\responses\transaction.response.dart

  File ini harus berisi kelas `TransactionResponse` dengan format `success`, `message`, dan `data` (list `TransactionModel`), seperti contoh pada bagian `transaction_remote.data_source.dart`.

Jika Anda ingin, saya bisa: 1) buatkan template file `transaction.dao.dart`/`transaction.table.dart` langsung di repo, atau 2) membuat contoh implementasi DAO dengan `sqflite`. Pilih opsi mana?
