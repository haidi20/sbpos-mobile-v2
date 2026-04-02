import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:setting/data/repositories/setting.repository.impl.dart';
import 'package:setting/domain/usecases/get_setting_config.usecase.dart';
import 'package:setting/domain/usecases/update_notification_preferences.usecase.dart';
import 'package:setting/domain/usecases/update_payment_methods.usecase.dart';
import 'package:setting/domain/usecases/update_printer_settings.usecase.dart';
import 'package:setting/domain/usecases/update_profile_settings.usecase.dart';
import 'package:setting/domain/usecases/update_security_settings.usecase.dart';
import 'package:setting/domain/usecases/update_store_info.usecase.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/view_models/setting.vm.dart';

import 'package:setting/testing/setting_test_fixtures.dart';

void main() {
  group('Setting provider injection', () {
    test('settingRepositoryProvider tetap bisa dibangun local-only', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repository = container.read(settingRepositoryProvider);

      expect(repository, isA<SettingRepositoryImpl>());
    });

    test('settingLocalDataSourceProvider menyuntikkan datasource konkret', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final local = container.read(settingLocalDataSourceProvider);

      expect(local, isA<SettingLocalDataSource>());
    });

    test('settingRepositoryProvider menyuntikkan SettingRepositoryImpl', () {
      final fakeRemote = FakeSettingRemoteDataSource();
      final fakeLocal = FakeSettingLocalDataSource();
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          settingLocalDataSourceProvider.overrideWithValue(fakeLocal),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(settingRepositoryProvider);

      expect(repository, isA<SettingRepositoryImpl>());
    });

    test('getSettingConfigProvider memakai repository injection yang sama',
        () async {
      final fakeRemote = FakeSettingRemoteDataSource();
      final fakeLocal = FakeSettingLocalDataSource();
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          settingLocalDataSourceProvider.overrideWithValue(fakeLocal),
        ],
      );
      addTearDown(container.dispose);

      final usecase = container.read(getSettingConfigProvider);

      expect(usecase, isA<GetSettingConfig>());
      final result = await usecase();
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (config) => expect(config.versionLabel, equals('SBPOS App v2.1.0')),
      );
      expect(fakeLocal.saveCallCount, equals(1));
    });

    test('updateStoreInfoProvider mengirim entity sebagai model ke remote',
        () async {
      final fakeRemote = FakeSettingRemoteDataSource();
      final fakeLocal = FakeSettingLocalDataSource();
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          settingLocalDataSourceProvider.overrideWithValue(fakeLocal),
        ],
      );
      addTearDown(container.dispose);

      final usecase = container.read(updateStoreInfoProvider);
      final result = await usecase(buildStoreInfoEntity());

      expect(usecase, isA<UpdateStoreInfo>());
      expect(fakeRemote.lastStoreInfoInput?.branch, equals('Samarinda Ulu'));
      expect(fakeLocal.storedConfig.store.branch, equals('Samarinda Ulu'));
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (store) => expect(store.storeName, equals('SB Coffee Samarinda')),
      );
    });

    test('updatePrinterSettingsProvider mengalirkan entity printer ke model',
        () async {
      final fakeRemote = FakeSettingRemoteDataSource();
      final fakeLocal = FakeSettingLocalDataSource();
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          settingLocalDataSourceProvider.overrideWithValue(fakeLocal),
        ],
      );
      addTearDown(container.dispose);

      final usecase = container.read(updatePrinterSettingsProvider);
      final result = await usecase(buildPrinterSettingsEntity());

      expect(usecase, isA<UpdatePrinterSettings>());
      expect(fakeRemote.lastPrinterSettingsInput?.paperWidth, equals('58mm'));
      expect(fakeLocal.storedConfig.printer.paperWidth, equals('58mm'));
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (printer) => expect(printer.devices.length, equals(2)),
      );
    });

    test('updatePaymentMethodsProvider mengalirkan list entity ke list model',
        () async {
      final fakeRemote = FakeSettingRemoteDataSource();
      final fakeLocal = FakeSettingLocalDataSource();
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          settingLocalDataSourceProvider.overrideWithValue(fakeLocal),
        ],
      );
      addTearDown(container.dispose);

      final usecase = container.read(updatePaymentMethodsProvider);
      final result = await usecase(buildPaymentMethodEntities());

      expect(usecase, isA<UpdatePaymentMethods>());
      expect(fakeRemote.lastPaymentMethodsInput?.length, equals(5));
      expect(fakeLocal.storedConfig.paymentMethods.length, equals(5));
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (methods) => expect(methods.last.name, equals('Transfer Bank')),
      );
    });

    test('updateProfileSettingsProvider mengalirkan entity profile ke model',
        () async {
      final fakeRemote = FakeSettingRemoteDataSource();
      final fakeLocal = FakeSettingLocalDataSource();
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          settingLocalDataSourceProvider.overrideWithValue(fakeLocal),
        ],
      );
      addTearDown(container.dispose);

      final usecase = container.read(updateProfileSettingsProvider);
      final result = await usecase(buildProfileSettingsEntity());

      expect(usecase, isA<UpdateProfileSettings>());
      expect(fakeRemote.lastProfileSettingsInput?.email, equals('sinta@sbpos.com'));
      expect(fakeLocal.storedConfig.profile.email, equals('sinta@sbpos.com'));
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (profile) => expect(profile.employeeId, equals('EMP-2026-002')),
      );
    });

    test(
        'updateNotificationPreferencesProvider mengalirkan entity notifikasi ke model',
        () async {
      final fakeRemote = FakeSettingRemoteDataSource();
      final fakeLocal = FakeSettingLocalDataSource();
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          settingLocalDataSourceProvider.overrideWithValue(fakeLocal),
        ],
      );
      addTearDown(container.dispose);

      final usecase = container.read(updateNotificationPreferencesProvider);
      final result = await usecase(buildNotificationPreferencesEntity());

      expect(usecase, isA<UpdateNotificationPreferences>());
      expect(fakeRemote.lastNotificationPreferencesInput?.stockAlert, isTrue);
      expect(fakeLocal.storedConfig.notifications.transactionSound, isTrue);
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (notification) => expect(notification.transactionSound, isTrue),
      );
    });

    test('updateSecuritySettingsProvider menulis state security aman ke lokal',
        () async {
      final fakeRemote = FakeSettingRemoteDataSource();
      final fakeLocal = FakeSettingLocalDataSource();
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          settingLocalDataSourceProvider.overrideWithValue(fakeLocal),
        ],
      );
      addTearDown(container.dispose);

      final usecase = container.read(updateSecuritySettingsProvider);
      final result = await usecase(buildSecuritySettingsEntity());

      expect(usecase, isA<UpdateSecuritySettings>());
      expect(fakeRemote.lastSecuritySettingsInput?.confirmPin, equals('222222'));
      expect(fakeLocal.storedConfig.security.oldPin, isEmpty);
      result.fold(
        (failure) => fail('Expected success but got $failure'),
        (ok) => expect(ok, isTrue),
      );
    });

    test('settingViewModelProvider tetap bisa diinjeksi terpisah dari data layer',
        () async {
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider
              .overrideWithValue(FakeSettingRemoteDataSource()),
          settingLocalDataSourceProvider
              .overrideWithValue(FakeSettingLocalDataSource()),
          printerFacadeProvider.overrideWithValue(FakePrinterFacade()),
        ],
      );
      addTearDown(container.dispose);

      final viewModel = container.read(settingViewModelProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel, isA<SettingViewModel>());
      expect(
        container.read(settingViewModelProvider).versionLabel,
        equals('SBPOS App v2.1.0'),
      );
    });

    test('selector provider store dan version membaca slice state yang tepat',
        () async {
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider
              .overrideWithValue(FakeSettingRemoteDataSource()),
          settingLocalDataSourceProvider
              .overrideWithValue(FakeSettingLocalDataSource()),
          printerFacadeProvider.overrideWithValue(FakePrinterFacade()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(settingViewModelProvider.notifier).getSettingConfig();

      final store = container.read(settingStoreStateProvider);
      final version = container.read(settingVersionLabelProvider);

      expect(store.storeName, equals('SB Coffee Samarinda'));
      expect(store.branch, equals('Samarinda Ulu'));
      expect(version, equals('SBPOS App v2.1.0'));
    });

    test('selector provider printer summary membaca printer yang terhubung',
        () async {
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider
              .overrideWithValue(FakeSettingRemoteDataSource()),
          settingLocalDataSourceProvider
              .overrideWithValue(FakeSettingLocalDataSource()),
          printerFacadeProvider.overrideWithValue(FakePrinterFacade()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(settingViewModelProvider.notifier).getSettingConfig();

      expect(
        container.read(settingPrinterSummaryProvider),
        equals('Epson TM-T82 (Terhubung)'),
      );
    });

    test('selector provider payment summary ikut berubah setelah toggle metode',
        () async {
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider
              .overrideWithValue(FakeSettingRemoteDataSource()),
          settingLocalDataSourceProvider
              .overrideWithValue(FakeSettingLocalDataSource()),
          printerFacadeProvider.overrideWithValue(FakePrinterFacade()),
        ],
      );
      addTearDown(container.dispose);

      final viewModel = container.read(settingViewModelProvider.notifier);
      await viewModel.getSettingConfig();
      viewModel.setPaymentMethodActive(5, true);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(settingPaymentSummaryProvider),
        contains('Transfer Bank'),
      );
    });

    test('selector provider notification summary merespons perubahan preferensi',
        () async {
      final container = ProviderContainer(
        overrides: [
          settingRemoteDataSourceProvider
              .overrideWithValue(FakeSettingRemoteDataSource()),
          settingLocalDataSourceProvider
              .overrideWithValue(FakeSettingLocalDataSource()),
          printerFacadeProvider.overrideWithValue(FakePrinterFacade()),
        ],
      );
      addTearDown(container.dispose);

      final viewModel = container.read(settingViewModelProvider.notifier);
      await viewModel.getSettingConfig();
      viewModel.setPushNotification(false);
      viewModel.setTransactionSound(false);
      viewModel.setStockAlert(false);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(settingNotificationSummaryProvider),
        equals('Semua notifikasi nonaktif'),
      );
    });
  });
}
