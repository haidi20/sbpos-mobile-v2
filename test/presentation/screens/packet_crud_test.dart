import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/data/datasources/db/packet.dao.dart';
import 'package:product/data/models/packet.model.dart';
import 'package:product/data/models/packet_item.model.dart';
import 'package:product/data/datasources/db/packet.table.dart' as packet_table;
import 'package:product/data/datasources/db/packet_item.table.dart'
    as packet_item_table;
import 'package:core/data/datasources/local_database_sembast.dart'
    as sembast_db;

import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.io) 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('packet CRUD uses real local DB', () async {
    if (kIsWeb) {
      await sembast_db.LocalDatabase.instance.init('test_packet_crud.db');
      await sembast_db.LocalDatabase.instance
          .deleteAll(packet_item_table.PacketItemTable.tableName);
      await sembast_db.LocalDatabase.instance
          .deleteAll(packet_table.PacketTable.tableName);

      final dao = PacketDao(null);

      final packet = PacketModel(name: 'Test Packet', price: 5000);
      final item = PacketItemModel(productId: 1, qty: 2, subtotal: 10000);

      final inserted = await dao.insertPacket(packet.toInsertDbLocal(),
          items: [item.toInsertDbLocal()]);
      expect(inserted.id, isNotNull);

      final list = await dao.getPackets();
      expect(list.length, greaterThanOrEqualTo(1));

      final fetched = await dao.getPacketById(inserted.id!);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Test Packet'));
      expect(fetched.items?.length, equals(1));

      // Update: create updated PacketModel and call update
      final updatedPacket = PacketModel.fromJson({
        'id': inserted.id,
        'id_server': inserted.idServer,
        'name': 'Updated Packet',
        'price': 20000
      });
      await dao.updatePacket(updatedPacket.toInsertDbLocal(),
          items: [item.toInsertDbLocal()]);
      final updated = await dao.getPacketById(inserted.id!);
      expect(updated!.name, equals('Updated Packet'));
      expect(updated.price, equals(20000));

      // Delete
      final del = await dao.deletePacket(inserted.id!);
      expect(del, greaterThanOrEqualTo(0));

      await sembast_db.LocalDatabase.instance
          .deleteAll(packet_item_table.PacketItemTable.tableName);
      await sembast_db.LocalDatabase.instance
          .deleteAll(packet_table.PacketTable.tableName);
      await sembast_db.LocalDatabase.instance.close();
    } else {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      await db.execute(packet_table.PacketTable.createTableQuery);
      await db.execute(packet_item_table.PacketItemTable.createTableQuery);

      final dao = PacketDao(db);

      final packet = PacketModel(name: 'Test Packet', price: 5000);
      final item = PacketItemModel(productId: 1, qty: 2, subtotal: 10000);

      final inserted = await dao.insertPacket(packet.toInsertDbLocal(),
          items: [item.toInsertDbLocal()]);
      expect(inserted.id, isNotNull);

      final list = await dao.getPackets();
      expect(list.length, greaterThanOrEqualTo(1));

      final fetched = await dao.getPacketById(inserted.id!);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Test Packet'));
      expect(fetched.items?.length, equals(1));

      // Update
      await db.update(packet_table.PacketTable.tableName,
          {'name': 'Updated Packet', 'price': 20000},
          where: '${packet_table.PacketTable.colId} = ?',
          whereArgs: [inserted.id]);
      final updated = await dao.getPacketById(inserted.id!);
      expect(updated!.name, equals('Updated Packet'));
      expect(updated.price, equals(20000));

      // Delete
      final del = await dao.deletePacket(inserted.id!);
      expect(del, greaterThanOrEqualTo(0));

      await db.close();
    }
  });
}
