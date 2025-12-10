import 'package:core/core.dart';
import 'customer.table.dart';
import 'package:customer/data/models/customer.model.dart';

class CustomerDao {
  final Database database;
  final _logger = Logger('CustomerDao');
  final bool isShowLog = false;

  CustomerDao(this.database);

  void _logInfo(String message) {
    if (isShowLog) _logger.info(message);
  }

  void _logSevere(String message, [Object? error, StackTrace? stack]) {
    if (isShowLog) _logger.severe(message, error, stack);
  }

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final rows = await database.query(CustomerTable.tableName);
      final list = rows.map((e) => CustomerModel.fromDbLocal(e)).toList();
      _logInfo('getCustomers: success count=${list.length}');
      return list;
    } catch (e, s) {
      _logSevere('Error getCustomers: $e', e, s);
      rethrow;
    }
  }

  Future<CustomerModel?> getCustomerById(int id) async {
    try {
      final rows = await database.query(
        CustomerTable.tableName,
        where: '${CustomerTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final model = CustomerModel.fromDbLocal(rows.first);
      _logInfo('getCustomerById: success id=$id');
      return model;
    } catch (e, s) {
      _logSevere('Error getCustomerById: $e', e, s);
      rethrow;
    }
  }

  Future<CustomerModel> insertCustomer(Map<String, dynamic> data) async {
    try {
      return await database.transaction((txn) async {
        final cleaned = Map<String, dynamic>.from(data)
          ..removeWhere((k, v) => v == null);
        final id = await txn.insert(CustomerTable.tableName, cleaned);
        final inserted = await txn.query(
          CustomerTable.tableName,
          where: '${CustomerTable.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );
        final model = CustomerModel.fromDbLocal(inserted.first);
        _logInfo('insertCustomer: success id=${model.id}');
        return model;
      });
    } catch (e, s) {
      _logSevere('Error insertCustomer: $e', e, s);
      rethrow;
    }
  }

  Future<int> updateCustomer(Map<String, dynamic> data) async {
    try {
      final id = data[CustomerTable.colId] ?? data['id'];
      final cleaned = Map<String, dynamic>.from(data)
        ..removeWhere((k, v) => v == null);
      cleaned.remove('id');
      final count = await database.update(
        CustomerTable.tableName,
        cleaned,
        where: '${CustomerTable.colId} = ?',
        whereArgs: [id],
      );
      _logInfo('updateCustomer: success id=$id rows=$count');
      return count;
    } catch (e, s) {
      _logSevere('Error updateCustomer: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteCustomer(int id) async {
    try {
      final count = await database.delete(
        CustomerTable.tableName,
        where: '${CustomerTable.colId} = ?',
        whereArgs: [id],
      );
      _logInfo('deleteCustomer: success id=$id rows=$count');
      return count;
    } catch (e, s) {
      _logSevere('Error deleteCustomer: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearCustomers() async {
    try {
      final count = await database.delete(CustomerTable.tableName);
      _logInfo('clearCustomers: success rows=$count');
      return count;
    } catch (e, s) {
      _logSevere('Error clearCustomers: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearSyncedAt(int id) async {
    try {
      final count = await database.rawUpdate(
        'UPDATE ${CustomerTable.tableName} SET ${CustomerTable.colSyncedAt} = NULL WHERE ${CustomerTable.colId} = ?',
        [id],
      );
      _logInfo('clearSyncedAt: success id=$id rows=$count');
      return count;
    } catch (e, s) { 
      _logSevere('Error clearSyncedAt: $e', e, s);
      rethrow;
    }
  }
}
