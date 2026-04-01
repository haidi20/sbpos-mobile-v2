import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/data/repositories/setting.repository.impl.dart';

import '../../setting_test_fixtures.dart';

void main() {
  late FakeSettingRemoteDataSource remote;
  late FakeSettingLocalDataSource local;
  late SettingRepositoryImpl repository;

  setUp(() {
    remote = FakeSettingRemoteDataSource();
    local = FakeSettingLocalDataSource();
    repository = SettingRepositoryImpl(
      remote: remote,
      local: local,
    );
  });

  group('SettingRepositoryImpl', () {
    test('getSettingConfig memetakan remote dan sinkron ke local', () async {
      final result = await repository.getSettingConfig();

      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (config) {
          expect(config.store.storeName, equals('SB Coffee Samarinda'));
          expect(config.printer.devices.length, equals(2));
          expect(config.paymentMethods.length, equals(5));
          expect(config.profile.email, equals('sinta@sbpos.com'));
          expect(config.notifications.transactionSound, isTrue);
          expect(config.security.oldPin, isEmpty);
        },
      );
      expect(local.saveCallCount, equals(1));
      expect(local.storedConfig.versionLabel, equals('SBPOS App v2.1.0'));
    });

    test('getSettingConfig offline mengembalikan config lokal', () async {
      await local.saveSettingConfig(buildSettingConfigModel());

      final result = await repository.getSettingConfig(isOffline: true);

      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (config) => expect(config.store.branch, equals('Samarinda Ulu')),
      );
      expect(remote.lastStoreInfoInput, isNull);
    });

    test('getSettingConfig fallback ke lokal saat remote error', () async {
      await local.saveSettingConfig(buildSettingConfigModel());
      remote.getSettingConfigError = NetworkException('offline');

      final result = await repository.getSettingConfig();

      result.fold(
        (failure) => fail('Expected local fallback but got $failure'),
        (config) => expect(config.store.storeName, equals('SB Coffee Samarinda')),
      );
    });

    test('updateStoreInfo menulis ke local sebelum remote', () async {
      final result = await repository.updateStoreInfo(buildStoreInfoEntity());

      expect(local.storedConfig.store.branch, equals('Samarinda Ulu'));
      expect(remote.lastStoreInfoInput?.storeName, equals('SB Coffee Samarinda'));
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (store) => expect(store.branch, equals('Samarinda Ulu')),
      );
    });

    test('updateStoreInfo offline tetap sukses lewat local', () async {
      final result = await repository.updateStoreInfo(
        buildStoreInfoEntity(),
        isOffline: true,
      );

      expect(local.storedConfig.store.storeName, equals('SB Coffee Samarinda'));
      expect(remote.lastStoreInfoInput, isNull);
      result.fold(
        (failure) => fail('Expected local success but got $failure'),
        (store) => expect(store.storeName, equals('SB Coffee Samarinda')),
      );
    });

    test(
        'updatePrinterSettings mengirim model printer dan langsung simpan lokal',
        () async {
      final result = await repository.updatePrinterSettings(
        buildPrinterSettingsEntity(),
      );

      expect(local.storedConfig.printer.paperWidth, equals('58mm'));
      expect(remote.lastPrinterSettingsInput?.paperWidth, equals('58mm'));
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (printer) {
          expect(printer.autoPrint, isTrue);
          expect(printer.devices.first.name, equals('Epson TM-T82'));
        },
      );
    });

    test('updatePaymentMethods mengirim list model dan simpan lokal',
        () async {
      final result = await repository.updatePaymentMethods(
        buildPaymentMethodEntities(),
      );

      expect(local.storedConfig.paymentMethods.length, equals(5));
      expect(remote.lastPaymentMethodsInput?.last.name, equals('Transfer Bank'));
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (methods) => expect(methods.first.isActive, isTrue),
      );
    });

    test('updateProfileSettings mengirim model profile dan simpan lokal',
        () async {
      final result = await repository.updateProfileSettings(
        buildProfileSettingsEntity(),
      );

      expect(local.storedConfig.profile.employeeId, equals('EMP-2026-002'));
      expect(remote.lastProfileSettingsInput?.employeeId, equals('EMP-2026-002'));
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (profile) => expect(profile.name, equals('Sinta Dewi')),
      );
    });

    test(
        'updateNotificationPreferences mengirim model notifikasi dan simpan lokal',
        () async {
      final result = await repository.updateNotificationPreferences(
        buildNotificationPreferencesEntity(),
      );

      expect(local.storedConfig.notifications.transactionSound, isTrue);
      expect(remote.lastNotificationPreferencesInput?.transactionSound, isTrue);
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (notification) => expect(notification.stockAlert, isTrue),
      );
    });

    test('updateSecuritySettings tidak menyimpan pin plaintext ke lokal',
        () async {
      final result = await repository.updateSecuritySettings(
        buildSecuritySettingsEntity(),
      );

      expect(remote.lastSecuritySettingsInput?.oldPin, equals('111111'));
      expect(local.storedConfig.security.oldPin, isEmpty);
      expect(local.storedConfig.security.newPin, isEmpty);
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (ok) => expect(ok, isTrue),
      );
    });

    test(
        'updateProfileSettings menangani NetworkException namun local sudah terbarui',
        () async {
      remote.updateProfileSettingsError = NetworkException('no internet');

      final result = await repository.updateProfileSettings(
        buildProfileSettingsEntity(),
      );

      expect(local.storedConfig.profile.name, equals('Sinta Dewi'));
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected network failure'),
      );
    });
  });
}
