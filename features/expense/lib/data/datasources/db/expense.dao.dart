import 'package:core/core.dart';
import 'package:expense/data/models/expense.model.dart';
import 'package:expense/data/datasources/db/expense.table.dart';
import 'package:core/data/datasources/local_database_sembast.dart' as sembast_db;

class ExpenseDao {
  final Database? database;
  final _logger = Logger('ExpenseDao');
  final bool isShowLog = false;

  ExpenseDao(this.database);

  void _logInfo(String message) {
    if (isShowLog) _logger.info(message);
  }

  void _logSevere(String message, [Object? error, StackTrace? stack]) {
    if (isShowLog) _logger.severe(message, error, stack);
  }

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      if (database != null) {
        final rows = await database!.query(
          ExpenseTable.tableName,
          orderBy: '${ExpenseTable.colCreatedAt} DESC',
        );
        final list = rows.map((e) => ExpenseModel.fromDbLocal(e)).toList();
        _logInfo('getExpenses: success count=${list.length}');
        return list;
      }

      final rows = await sembast_db.LocalDatabase.instance
          .getAll(ExpenseTable.tableName);
      // Sembast doesn't have SQL-like order by in the helper, we'll sort manually if needed
      final list = rows.map((e) => ExpenseModel.fromDbLocal(e)).toList()
        ..sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
      _logInfo('getExpenses (web): success count=${list.length}');
      return list;
    } catch (e, s) {
      _logSevere('Error getExpenses: $e', e, s);
      rethrow;
    }
  }

  Future<ExpenseModel> insertExpense(Map<String, dynamic> data) async {
    try {
      if (database != null) {
        return await database!.transaction((txn) async {
          final cleaned = Map<String, dynamic>.from(data)
            ..removeWhere((k, v) => v == null);
          final id = await txn.insert(ExpenseTable.tableName, cleaned);
          final inserted = await txn.query(
            ExpenseTable.tableName,
            where: '${ExpenseTable.colId} = ?',
            whereArgs: [id],
            limit: 1,
          );
          final model = ExpenseModel.fromDbLocal(inserted.first);
          _logInfo('insertExpense: success id=${model.id}');
          return model;
        });
      }

      final cleaned = Map<String, dynamic>.from(data)
        ..removeWhere((k, v) => v == null);
      if (cleaned.containsKey('id')) cleaned.remove('id'); // let sembast auto-key if needed
      
      final key = await sembast_db.LocalDatabase.instance
          .insert(ExpenseTable.tableName, cleaned);
      final map = await sembast_db.LocalDatabase.instance
          .getByKey(ExpenseTable.tableName, key);
      final model = ExpenseModel.fromDbLocal(map!);
      _logInfo('insertExpense (web): success id=${model.id}');
      return model;
    } catch (e, s) {
      _logSevere('Error insertExpense: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearSyncedAt(int id) async {
    try {
      if (database != null) {
        final count = await database!.rawUpdate(
          'UPDATE ${ExpenseTable.tableName} SET ${ExpenseTable.colSyncedAt} = NULL WHERE ${ExpenseTable.colId} = ?',
          [id],
        );
        _logInfo('clearSyncedAt: success id=$id rows=$count');
        return count;
      }

      final map = await sembast_db.LocalDatabase.instance
          .getByKey(ExpenseTable.tableName, id);
      if (map == null) return 0;
      map[ExpenseTable.colSyncedAt] = null;
      await sembast_db.LocalDatabase.instance
          .put(ExpenseTable.tableName, id, map);
      _logInfo('clearSyncedAt (web): success id=$id');
      return 1;
    } catch (e, s) {
      _logSevere('Error clearSyncedAt: $e', e, s);
      rethrow;
    }
  }

  Future<int> updateExpense(Map<String, dynamic> data) async {
    try {
      final id = data['id'] as int;
      final cleaned = Map<String, dynamic>.from(data)
        ..removeWhere((k, v) => v == null);
      cleaned.remove('id');
      
      if (database != null) {
        final count = await database!.update(
          ExpenseTable.tableName,
          cleaned,
          where: '${ExpenseTable.colId} = ?',
          whereArgs: [id],
        );
        return count;
      }

      await sembast_db.LocalDatabase.instance
          .put(ExpenseTable.tableName, id, cleaned);
      return 1;
    } catch (e, s) {
      _logSevere('Error updateExpense: $e', e, s);
      rethrow;
    }
  }
}
