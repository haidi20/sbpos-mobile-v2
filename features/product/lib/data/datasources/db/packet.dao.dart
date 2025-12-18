import 'packet.table.dart';
import 'packet_item.table.dart';
import 'package:core/core.dart';
import 'package:product/data/models/packet.model.dart';
import 'package:product/data/models/packet_item.model.dart';

class PacketDao {
  final Database database;
  final _logger = Logger('PacketDao');
  final bool isShowLog = false;

  void _logInfo(String message) {
    if (isShowLog) _logger.info(message);
  }

  void _logSevere(String message, [Object? error, StackTrace? stack]) {
    if (isShowLog) _logger.severe(message, error, stack);
  }

  PacketDao(this.database);

  Future<List<PacketModel>> getPackets({int? limit, int? offset}) async {
    try {
      final rows = await database.query(
        PacketTable.tableName,
        limit: limit,
        offset: offset,
      );

      final List<PacketModel> result = [];
      for (final r in rows) {
        final id = r[PacketTable.colId] as int?;
        final items =
            id == null ? <PacketItemModel>[] : await _getItemsForPacket(id);
        result.add(PacketModel.fromDbLocal(r, items: items));
      }
      _logInfo('getPackets: success count=${result.length}');
      return result;
    } catch (e, s) {
      _logSevere('Error getPackets: $e', e, s);
      rethrow;
    }
  }

  Future<PacketModel?> getPacketById(int id) async {
    try {
      final rows = await database.query(
        PacketTable.tableName,
        where: '${PacketTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final model = PacketModel.fromDbLocal(rows.first,
          items: await _getItemsForPacket(id));
      _logInfo('getPacketById: success id=$id');
      return model;
    } catch (e, s) {
      _logSevere('Error getPacketById: $e', e, s);
      rethrow;
    }
  }

  Future<List<PacketItemModel>> _getItemsForPacket(int packetId) async {
    final rows = await database.query(PacketItemTable.tableName,
        where: '${PacketItemTable.colPacketId} = ?', whereArgs: [packetId]);
    return rows.map((r) => PacketItemModel.fromDbLocal(r)).toList();
  }

  Future<PacketModel> insertPacket(Map<String, dynamic> packet,
      {List<Map<String, dynamic>>? items}) async {
    try {
      return await database.transaction((txn) async {
        final cleaned = Map<String, dynamic>.from(packet)
          ..removeWhere((k, v) => v == null);
        final id = await txn.insert(PacketTable.tableName, cleaned);
        if (items != null && items.isNotEmpty) {
          for (final it in items) {
            final i = Map<String, dynamic>.from(it)
              ..removeWhere((k, v) => v == null);
            i[PacketItemTable.colPacketId] = id;
            await txn.insert(PacketItemTable.tableName, i);
          }
        }

        final inserted = await txn.query(
          PacketTable.tableName,
          where: '${PacketTable.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );

        // Fetch items using the transaction to avoid acquiring a separate DB lock
        final itemRows = await txn.query(
          PacketItemTable.tableName,
          where: '${PacketItemTable.colPacketId} = ?',
          whereArgs: [id],
        );
        final itemModels =
            itemRows.map((r) => PacketItemModel.fromDbLocal(r)).toList();

        final model = PacketModel.fromDbLocal(
          inserted.first as Map<String, dynamic>,
          items: itemModels,
        );
        _logInfo('insertPacket: success id=${model.id}');
        return model;
      });
    } catch (e, s) {
      _logSevere('Error insertPacket: $e', e, s);
      rethrow;
    }
  }

  Future<PacketModel?> getPacketByServerId(int idServer) async {
    try {
      final rows = await database.query(
        PacketTable.tableName,
        where: '${PacketTable.colIdServer} = ?',
        whereArgs: [idServer],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final id = rows.first[PacketTable.colId] as int?;
      final model = PacketModel.fromDbLocal(rows.first,
          items:
              id == null ? <PacketItemModel>[] : await _getItemsForPacket(id));
      _logInfo(
          'getPacketByServerId: success id_server=$idServer -> id=${model.id}');
      return model;
    } catch (e, s) {
      _logSevere('Error getPacketByServerId: $e', e, s);
      rethrow;
    }
  }

  Future<PacketModel> upsertPacket(Map<String, dynamic> packet,
      {List<Map<String, dynamic>>? items}) async {
    try {
      return await database.transaction((txn) async {
        final idServer = packet[PacketTable.colIdServer];
        if (idServer != null) {
          final existingRows = await txn.query(
            PacketTable.tableName,
            where: '${PacketTable.colIdServer} = ?',
            whereArgs: [idServer],
            limit: 1,
          );
          if (existingRows.isNotEmpty) {
            final existingId = existingRows.first[PacketTable.colId] as int?;
            final cleaned = Map<String, dynamic>.from(packet)
              ..removeWhere((k, v) => v == null);
            cleaned.remove('id');
            await txn.update(
              PacketTable.tableName,
              cleaned,
              where: '${PacketTable.colId} = ?',
              whereArgs: [existingId],
            );
            if (items != null) {
              await txn.delete(PacketItemTable.tableName,
                  where: '${PacketItemTable.colPacketId} = ?',
                  whereArgs: [existingId]);
              for (final it in items) {
                final i = Map<String, dynamic>.from(it)
                  ..removeWhere((k, v) => v == null);
                i[PacketItemTable.colPacketId] = existingId;
                await txn.insert(PacketItemTable.tableName, i);
              }
            }
            final updatedRows = await txn.query(
              PacketTable.tableName,
              where: '${PacketTable.colId} = ?',
              whereArgs: [existingId],
              limit: 1,
            );
            final itemRows = await txn.query(
              PacketItemTable.tableName,
              where: '${PacketItemTable.colPacketId} = ?',
              whereArgs: [existingId],
            );
            final itemModels =
                itemRows.map((r) => PacketItemModel.fromDbLocal(r)).toList();
            final model = PacketModel.fromDbLocal(
                updatedRows.first as Map<String, dynamic>,
                items: itemModels);
            _logInfo(
                'upsertPacket: updated id=${model.id} id_server=$idServer');
            return model;
          }
        }

        // insert new
        final cleaned = Map<String, dynamic>.from(packet)
          ..removeWhere((k, v) => v == null);
        final id = await txn.insert(PacketTable.tableName, cleaned);
        if (items != null && items.isNotEmpty) {
          for (final it in items) {
            final i = Map<String, dynamic>.from(it)
              ..removeWhere((k, v) => v == null);
            i[PacketItemTable.colPacketId] = id;
            await txn.insert(PacketItemTable.tableName, i);
          }
        }
        final inserted = await txn.query(
          PacketTable.tableName,
          where: '${PacketTable.colId} = ?',
          whereArgs: [id],
          limit: 1,
        );
        final itemRows = await txn.query(
          PacketItemTable.tableName,
          where: '${PacketItemTable.colPacketId} = ?',
          whereArgs: [id],
        );
        final itemModels =
            itemRows.map((r) => PacketItemModel.fromDbLocal(r)).toList();
        final model = PacketModel.fromDbLocal(
            inserted.first as Map<String, dynamic>,
            items: itemModels);
        _logInfo(
            'upsertPacket: inserted id=${model.id} id_server=${packet[PacketTable.colIdServer]}');
        return model;
      });
    } catch (e, s) {
      _logSevere('Error upsertPacket: $e', e, s);
      rethrow;
    }
  }

  Future<int> updatePacket(Map<String, dynamic> packet,
      {List<Map<String, dynamic>>? items}) async {
    try {
      final id = packet['id'];
      final cleaned = Map<String, dynamic>.from(packet)
        ..removeWhere((k, v) => v == null);
      cleaned.remove('id');
      return await database.transaction((txn) async {
        final res = await txn.update(
          PacketTable.tableName,
          cleaned,
          where: '${PacketTable.colId} = ?',
          whereArgs: [id],
        );
        if (items != null) {
          // simple approach: delete existing items and insert new
          await txn.delete(PacketItemTable.tableName,
              where: '${PacketItemTable.colPacketId} = ?', whereArgs: [id]);
          for (final it in items) {
            final i = Map<String, dynamic>.from(it)
              ..removeWhere((k, v) => v == null);
            i[PacketItemTable.colPacketId] = id;
            await txn.insert(PacketItemTable.tableName, i);
          }
        }
        _logInfo('updatePacket: success id=$id');
        return res;
      });
    } catch (e, s) {
      _logSevere('Error updatePacket: $e', e, s);
      rethrow;
    }
  }

  Future<int> deletePacket(int id) async {
    try {
      return await database.transaction((txn) async {
        await txn.delete(PacketItemTable.tableName,
            where: '${PacketItemTable.colPacketId} = ?', whereArgs: [id]);
        final res = await txn.delete(
          PacketTable.tableName,
          where: '${PacketTable.colId} = ?',
          whereArgs: [id],
        );
        _logInfo('deletePacket: success id=$id rows=$res');
        return res;
      });
    } catch (e, s) {
      _logSevere('Error deletePacket: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearPackets() async {
    try {
      return await database.transaction((txn) async {
        await txn.delete(PacketItemTable.tableName);
        final res = await txn.delete(PacketTable.tableName);
        _logInfo('clearPackets: success rows=$res');
        return res;
      });
    } catch (e, s) {
      _logSevere('Error clearPackets: $e', e, s);
      rethrow;
    }
  }
}
