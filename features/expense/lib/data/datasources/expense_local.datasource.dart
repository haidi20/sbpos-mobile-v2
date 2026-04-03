import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:expense/data/models/expense.model.dart';
import 'package:expense/data/datasources/db/expense.dao.dart';

class ExpenseLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final Database? _testDb;
  final _logger = Logger('ExpenseLocalDataSource');
  final bool isShowLog = false;

  ExpenseLocalDataSource({Database? testDb}) : _testDb = testDb;

  void _logInfo(String msg) {
    if (isShowLog) _logger.info(msg);
  }

  void _logSevere(String msg, [Object? e, StackTrace? st]) {
    if (isShowLog) _logger.severe(msg, e, st);
  }

  @visibleForTesting
  ExpenseDao createDao(Database db) => ExpenseDao(db);

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      return await dao.getExpenses();
    } catch (e, st) {
      _logSevere('Error getExpenses', e, st);
      rethrow;
    }
  }

  Future<ExpenseModel?> insertExpense(ExpenseModel expense) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      final map = expense.toInsertDbLocal();
      return await dao.insertExpense(map);
    } catch (e, st) {
      _logSevere('Error insertExpense', e, st);
      rethrow;
    }
  }

  Future<int> updateExpense(Map<String, dynamic> data) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      return await dao.updateExpense(data);
    } catch (e, st) {
      _logSevere('Error updateExpense', e, st);
      rethrow;
    }
  }

  Future<int> clearSyncedAt(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      final dao = createDao(db);
      return await dao.clearSyncedAt(id);
    } catch (e, st) {
      _logSevere('Error clearSyncedAt', e, st);
      rethrow;
    }
  }
}
