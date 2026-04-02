import 'package:flutter_test/flutter_test.dart';
import 'package:setting/data/datasources/db/setting.dao.dart';
import 'package:setting/data/datasources/db/setting.table.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:setting/testing/setting_test_fixtures.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SettingDao integration', () {
    late Database db;
    late SettingDao dao;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(SettingTable.createTableQuery);
      dao = SettingDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('upsertSettingConfig lalu getSettingConfig menyimpan aggregate setting',
        () async {
      final config = buildSettingConfigModel();

      final inserted = await dao.upsertSettingConfig(config.toDbLocal());
      final fetched = await dao.getSettingConfig();

      expect(inserted.store.storeName, equals('SB Coffee Samarinda'));
      expect(fetched, isNotNull);
      expect(fetched!.printer.devices.length, equals(2));
      expect(fetched.paymentMethods.length, equals(5));
      expect(fetched.profile.name, equals('Sinta Dewi'));
    });

    test('upsertSettingConfig kedua memperbarui row singleton yang sama',
        () async {
      await dao.upsertSettingConfig(buildSettingConfigModel().toDbLocal());

      final updatedConfig = buildSettingConfigModel().copyWith(
        store: buildStoreInfoModel().copyWith(storeName: 'SB Coffee Balikpapan'),
      );
      await dao.upsertSettingConfig(updatedConfig.toDbLocal());
      final fetched = await dao.getSettingConfig();

      expect(fetched, isNotNull);
      expect(fetched!.store.storeName, equals('SB Coffee Balikpapan'));

      final rows = await db.query(SettingTable.tableName);
      expect(rows.length, equals(1));
    });

    test('clearSettings menghapus config lokal', () async {
      await dao.upsertSettingConfig(buildSettingConfigModel().toDbLocal());

      final deleted = await dao.clearSettings();
      final fetched = await dao.getSettingConfig();

      expect(deleted, equals(1));
      expect(fetched, isNull);
    });
  });
}
