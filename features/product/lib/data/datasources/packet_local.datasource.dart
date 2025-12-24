import 'package:core/core.dart';
import 'package:product/data/models/packet.model.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:product/data/datasources/db/packet.dao.dart';

class PacketLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final Database? _testDb;
  final _logger = Logger('PacketLocalDataSource');
  final bool isShowLog = false;

  PacketLocalDataSource({Database? testDb}) : _testDb = testDb;

  void _logInfo(String msg) {
    if (isShowLog) _logger.info(msg);
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
  // Accept nullable Database so DAO can decide whether to use the native
  // `database` or fall back to the Sembast `LocalDatabase` implementation.
  PacketDao createDao(Database? db) => PacketDao(db);

  Future<List<PacketModel>> getPackets({int? limit, int? offset}) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logInfo(
            'Database is null; delegating to Sembast LocalDatabase (web).');
      }
      final dao = createDao(db);
      final result = await dao.getPackets(limit: limit, offset: offset);
      _logInfo('getPackets: count=${result.length}');
      return result;
    } catch (e, st) {
      _logSevere('Error getPackets', e, st);
      rethrow;
    }
  }

  Future<PacketModel?> getPacketById(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logInfo(
            'Database is null; delegating getPacketById to Sembast LocalDatabase (web).');
      }
      final dao = createDao(db);
      return await dao.getPacketById(id);
    } catch (e, st) {
      _logSevere('Error getPacketById', e, st);
      rethrow;
    }
  }

  Future<PacketModel?> insertPacket(PacketModel model,
      {List<Map<String, dynamic>>? items}) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logInfo(
            'Database is null; delegating insertPacket to Sembast LocalDatabase (web).');
      }
      final dao = createDao(db);
      final map = sanitizeForDb(model.toInsertDbLocal());
      final inserted = await _withRetry(
          () async => await dao.insertPacket(map, items: items));
      _logInfo('insertPacket: id=${inserted.id}');
      return inserted;
    } catch (e, st) {
      _logSevere('Error insertPacket', e, st);
      rethrow;
    }
  }

  Future<PacketModel?> upsertPacket(PacketModel model,
      {List<Map<String, dynamic>>? items}) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logInfo(
            'Database is null; delegating upsertPacket to Sembast LocalDatabase (web).');
      }
      final dao = createDao(db);
      final map = sanitizeForDb(model.toInsertDbLocal());
      final upserted = await _withRetry(
          () async => await dao.upsertPacket(map, items: items));
      _logInfo('upsertPacket: id=${upserted.id}');
      return upserted;
    } catch (e, st) {
      _logSevere('Error upsertPacket', e, st);
      rethrow;
    }
  }

  Future<int> updatePacket(Map<String, dynamic> data,
      {List<Map<String, dynamic>>? items}) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logInfo(
            'Database is null; delegating updatePacket to Sembast LocalDatabase (web).');
      }
      final dao = createDao(db);
      final map = sanitizeForDb(Map<String, dynamic>.from(data));
      if (data.containsKey('id')) map['id'] = data['id'];
      final updated = await dao.updatePacket(map, items: items);
      _logInfo('updatePacket: rows=$updated');
      return updated;
    } catch (e, st) {
      _logSevere('Error updatePacket', e, st);
      rethrow;
    }
  }

  Future<int> deletePacket(int id) async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logInfo(
            'Database is null; delegating deletePacket to Sembast LocalDatabase (web).');
      }
      final dao = createDao(db);
      final count = await dao.deletePacket(id);
      _logInfo('deletePacket: rows=$count');
      return count;
    } catch (e, st) {
      _logSevere('Error deletePacket', e, st);
      rethrow;
    }
  }

  Future<int> clearPackets() async {
    try {
      final db = _testDb ?? await databaseHelper.database;
      if (db == null) {
        _logInfo(
            'Database is null; delegating clearPackets to Sembast LocalDatabase (web).');
      }
      final dao = createDao(db);
      return await dao.clearPackets();
    } catch (e, st) {
      _logSevere('Error clearPackets', e, st);
      rethrow;
    }
  }
}
