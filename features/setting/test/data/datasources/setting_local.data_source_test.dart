import 'package:flutter_test/flutter_test.dart';
import 'package:setting/data/datasources/db/setting.table.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:setting/testing/setting_test_fixtures.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SettingLocalDataSource', () {
    late Database db;
    late SettingLocalDataSource local;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(SettingTable.createTableQuery);
      local = SettingLocalDataSource(testDb: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('getSettingConfig men-seed config default ke db lokal bila tabel kosong',
        () async {
      final config = await local.getSettingConfig();
      final rows = await db.query(SettingTable.tableName);

      expect(config.store.storeName, equals('SB Coffee'));
      expect(config.paymentMethods.length, equals(5));
      expect(config.security.oldPin, isEmpty);
      expect(rows.length, equals(1));
      expect(rows.first['store_name'], equals('SB Coffee'));
    });

    test('saveSettingConfig langsung tersimpan ke db lokal', () async {
      final saved = await local.saveSettingConfig(buildSettingConfigModel());
      final fetched = await local.getSettingConfig();

      expect(saved.store.branch, equals('Samarinda Ulu'));
      expect(fetched.printer.paperWidth, equals('58mm'));
      expect(fetched.profile.employeeId, equals('EMP-2026-002'));
    });

    test('saveSettingConfig kedua menimpa nilai sebelumnya', () async {
      await local.saveSettingConfig(buildSettingConfigModel());
      await local.saveSettingConfig(
        buildSettingConfigModel().copyWith(
          notifications: buildNotificationPreferencesModel().copyWith(
            transactionSound: false,
          ),
        ),
      );

      final fetched = await local.getSettingConfig();

      expect(fetched.notifications.transactionSound, isFalse);
    });
  });
}
