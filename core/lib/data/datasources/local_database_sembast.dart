import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:logging/logging.dart';

/// Implementasi LocalDatabase sederhana berbasis Sembast untuk web.
class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  Database? _db;
  final _logger = Logger('LocalDatabase');

  Future<void> init([String dbName = 'app_sembast.db']) async {
    if (_db != null) return;
    final factory = databaseFactoryWeb;
    _db = await factory.openDatabase(dbName);
    _logger.info('Sembast DB initialized: $dbName');
  }

  Future<int> insert(String storeName, Map<String, dynamic> value) async {
    if (_db == null) await init();
    final store = intMapStoreFactory.store(storeName);
    final key = await store.add(_db!, value);
    _logger.info('insert into $storeName -> key=$key');
    return key;
  }

  Future<List<Map<String, dynamic>>> getAll(String storeName) async {
    if (_db == null) await init();
    final store = intMapStoreFactory.store(storeName);
    final records = await store.find(_db!);
    _logger.info('getAll from $storeName -> count=${records.length}');
    return records.map((r) {
      final map = Map<String, dynamic>.from(r.value);
      map['_id'] = r.key;
      map['id'] = r.key;
      return map;
    }).toList();
  }

  Future<int> deleteAll(String storeName) async {
    if (_db == null) await init();
    final store = intMapStoreFactory.store(storeName);
    await store.delete(_db!);
    return 0;
  }

  /// Delete a record by integer key.
  Future<int> deleteByKey(String storeName, int key) async {
    if (_db == null) await init();
    final store = intMapStoreFactory.store(storeName);
    await store.record(key).delete(_db!);
    return 1;
  }

  /// Get records where [field] equals [value].
  Future<List<Map<String, dynamic>>> getWhereEquals(
      String storeName, String field, dynamic value) async {
    if (_db == null) await init();
    final store = intMapStoreFactory.store(storeName);
    final finder = Finder(filter: Filter.equals(field, value));
    final records = await store.find(_db!, finder: finder);
    return records.map((r) {
      final map = Map<String, dynamic>.from(r.value);
      map['_id'] = r.key;
      map['id'] = r.key;
      return map;
    }).toList();
  }

  /// Delete records where [field] equals [value]. Returns number of deleted records.
  Future<int> deleteWhereEquals(
      String storeName, String field, dynamic value) async {
    if (_db == null) await init();
    final store = intMapStoreFactory.store(storeName);
    final finder = Finder(filter: Filter.equals(field, value));
    final deleted = await store.delete(_db!, finder: finder);
    return deleted;
  }

  /// Get a single record by integer key. Returns a map with '_id' set to the key.
  Future<Map<String, dynamic>?> getByKey(String storeName, int key) async {
    if (_db == null) await init();
    final store = intMapStoreFactory.store(storeName);
    final value = await store.record(key).get(_db!);
    if (value == null) return null;
    final map = Map<String, dynamic>.from(value as Map);
    map['_id'] = key;
    map['id'] = key;
    return map;
  }

  /// Put (insert or update) a record with a given integer key.
  Future<void> put(
      String storeName, int key, Map<String, dynamic> value) async {
    if (_db == null) await init();
    final store = intMapStoreFactory.store(storeName);
    await store.record(key).put(_db!, value);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
