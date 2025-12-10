import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:customer/data/models/customer.model.dart';
import 'package:customer/data/datasources/db/customer.dao.dart';

class LocalCustomerDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final Database? _testDb;
  final _logger = Logger('LocalCustomerDataSource');
  final bool isShowLog = false;

  LocalCustomerDataSource({Database? testDb}) : _testDb = testDb;

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
  CustomerDao createDao(Database db) => CustomerDao(db);

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat getCustomers');
        return [];
      }
      final dao = createDao(db);
      final result = await dao.getCustomers();
      _logInfo('getCustomers: count=${result.length}');
      return result;
    } catch (e, st) {
      _logSevere('Error getCustomers', e, st);
      rethrow;
    }
  }

  Future<CustomerModel?> getCustomerById(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat getCustomerById');
        return null;
      }
      final dao = createDao(db);
      return await dao.getCustomerById(id);
    } catch (e, st) {
      _logSevere('Error getCustomerById', e, st);
      rethrow;
    }
  }

  Future<CustomerModel?> insertCustomer(CustomerModel customer) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat insertCustomer');
        return null;
      }
      final dao = createDao(db);
      final map = sanitizeForDb(customer.toInsertDbLocal());
      final inserted =
          await _withRetry(() async => await dao.insertCustomer(map));
      _logInfo('insertCustomer: id=${inserted.id}');
      return inserted;
    } catch (e, st) {
      _logSevere('Error insertCustomer', e, st);
      rethrow;
    }
  }

  Future<int> updateCustomer(Map<String, dynamic> data) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat updateCustomer');
        return 0;
      }
      final dao = createDao(db);
      final map = sanitizeForDb(Map<String, dynamic>.from(data));
      if (data.containsKey('id')) map['id'] = data['id'];
      final updated = await dao.updateCustomer(map);
      _logInfo('updateCustomer: rows=$updated');
      return updated;
    } catch (e, st) {
      _logSevere('Error updateCustomer', e, st);
      rethrow;
    }
  }

  Future<int> deleteCustomer(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat deleteCustomer');
        return 0;
      }
      final dao = createDao(db);
      final count = await dao.deleteCustomer(id);
      _logInfo('deleteCustomer: rows=$count');
      return count;
    } catch (e, st) {
      _logSevere('Error deleteCustomer', e, st);
      rethrow;
    }
  }

  Future<int> clearCustomers() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logWarning('Database null saat clearCustomers');
        return 0;
      }
      final dao = createDao(db);
      return await dao.clearCustomers();
    } catch (e, st) {
      _logSevere('Error clearCustomers', e, st);
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
