import 'package:flutter_test/flutter_test.dart';
import 'package:setting/data/repositories/setting.repository.impl.dart';
import 'package:setting/domain/usecases/get_setting_config.usecase.dart';
import 'package:setting/domain/usecases/update_notification_preferences.usecase.dart';
import 'package:setting/domain/usecases/update_payment_methods.usecase.dart';
import 'package:setting/domain/usecases/update_printer_settings.usecase.dart';
import 'package:setting/domain/usecases/update_profile_settings.usecase.dart';
import 'package:setting/domain/usecases/update_security_settings.usecase.dart';
import 'package:setting/domain/usecases/update_store_info.usecase.dart';
import 'package:setting/presentation/view_models/setting.vm.dart';

import 'package:setting/testing/setting_test_fixtures.dart';

void main() {
  late FakeSettingRemoteDataSource remote;
  late FakeSettingLocalDataSource local;
late FakePrinterFacade printerService;
  late SettingViewModel viewModel;

  setUp(() {
    remote = FakeSettingRemoteDataSource();
    local = FakeSettingLocalDataSource();
    printerService = FakePrinterFacade();
    final repository = SettingRepositoryImpl(
      remote: remote,
      local: local,
    );
    viewModel = SettingViewModel(
      getSettingConfig: GetSettingConfig(repository),
      updateStoreInfo: UpdateStoreInfo(repository),
      updatePrinterSettings: UpdatePrinterSettings(repository),
      updatePaymentMethods: UpdatePaymentMethods(repository),
      updateProfileSettings: UpdateProfileSettings(repository),
      updateNotificationPreferences: UpdateNotificationPreferences(repository),
      updateSecuritySettings: UpdateSecuritySettings(repository),
      printerFacade: printerService,
    );
  });

  group('SettingViewModel', () {
    test('getSettingConfig memuat state dari usecase dan sync printer config',
        () async {
      await viewModel.getSettingConfig();

      expect(viewModel.state.store.storeName, equals('SB Coffee Samarinda'));
      expect(viewModel.state.printer.paperWidth, equals('58mm'));
      expect(viewModel.state.profile.name, equals('Sinta Dewi'));
      expect(viewModel.state.versionLabel, equals('SBPOS App v2.1.0'));
      expect(printerService.syncConfigCallCount, equals(1));
      expect(printerService.lastConfig?.printerName, equals('Epson TM-T82'));
      expect(printerService.lastConfig?.paperWidth, equals('58mm'));
      expect(local.storedConfig.versionLabel, equals('SBPOS App v2.1.0'));
    });

    test('initial summary merefleksikan state awal feature setting', () {
      expect(viewModel.getStoreSummary, equals('SB Coffee - Jakarta Selatan'));
      expect(viewModel.getPrinterSummary, equals('Epson TM-T82 (Terhubung)'));
      expect(
        viewModel.getPaymentSummary,
        equals('Tunai (Cash), QRIS, Kartu Debit'),
      );
      expect(viewModel.getNotificationSummary, equals('Semua notifikasi aktif'));
    });

    test('onSaveStoreInfo gagal bila ada field wajib yang kosong', () async {
      viewModel.setStoreName('');

      final result = await viewModel.onSaveStoreInfo();

      expect(result, isFalse);
      expect(
        viewModel.state.store.errorMessage,
        equals('Semua field informasi toko wajib diisi'),
      );
    });

    test('onSaveStoreInfo berhasil saat form valid dan persist lokal',
        () async {
      viewModel.setStoreName('SB Coffee Samarinda');
      viewModel.setStoreBranch('Samarinda Ulu');
      viewModel.setStoreAddress('Jl. KH Wahid Hasyim No. 10');
      viewModel.setStorePhone('0812-1111-2222');

      final result = await viewModel.onSaveStoreInfo();

      expect(result, isTrue);
      expect(viewModel.state.store.storeName, equals('SB Coffee Samarinda'));
      expect(viewModel.state.store.successMessage, isNotEmpty);
      expect(
        viewModel.getStoreSummary,
        equals('SB Coffee Samarinda - Samarinda Ulu'),
      );
      expect(remote.lastStoreInfoInput?.storeName, equals('SB Coffee Samarinda'));
      expect(local.storedConfig.store.storeName, equals('SB Coffee Samarinda'));
    });

    test(
        'setPaymentMethodActive mengubah status metode pembayaran dan persist lokal',
        () async {
      viewModel.setPaymentMethodActive(5, true);
      await Future<void>.delayed(Duration.zero);

      final transferBank =
          viewModel.state.payment.methods.firstWhere((method) => method.id == 5);

      expect(transferBank.isActive, isTrue);
      expect(viewModel.getPaymentSummary, contains('Transfer Bank'));
      expect(
        local.storedConfig.paymentMethods.firstWhere((method) => method.id == 5).isActive,
        isTrue,
      );
    });

    test(
        'perubahan printer persist lokal dan tetap sync ke printer service',
        () async {
      viewModel.setPrinterPaperWidth('58mm');
      viewModel.setPrinterConnected('Epson TM-T82', false);
      await Future<void>.delayed(Duration.zero);

      expect(printerService.lastConfig?.paperWidth, equals('58mm'));
      expect(local.storedConfig.printer.paperWidth, equals('58mm'));
      expect(local.storedConfig.printer.devices.first.isConnected, isFalse);
    });

    test(
        'onTestPrint gagal bila tidak ada printer aktif dan sukses via printer service saat terhubung',
        () async {
      viewModel.setPrinterConnected('Epson TM-T82', false);
      await Future<void>.delayed(Duration.zero);

      final failedResult = await viewModel.onTestPrint();
      expect(failedResult, isFalse);
      expect(viewModel.state.printer.isError, isTrue);
      expect(printerService.testPrintCallCount, equals(0));

      viewModel.setPrinterConnected('Epson TM-T82', true);
      final successResult = await viewModel.onTestPrint();
      expect(successResult, isTrue);
      expect(viewModel.state.printer.isError, isFalse);
      expect(printerService.testPrintCallCount, equals(1));
      expect(remote.lastPrinterSettingsInput?.paperWidth, equals('80mm'));
    });

    test('onSaveProfile memvalidasi email dan memperbarui nama profile card',
        () async {
      viewModel.setProfileName('Kasir Baru');
      viewModel.setProfileEmail('email-tidak-valid');
      viewModel.setProfilePhone('0812-0000-0000');

      final failedResult = await viewModel.onSaveProfile();
      expect(failedResult, isFalse);
      expect(viewModel.state.profile.errorMessage, equals('Format email tidak valid'));

      viewModel.setProfileEmail('kasir.baru@sbpos.com');
      final successResult = await viewModel.onSaveProfile();

      expect(successResult, isTrue);
      expect(viewModel.state.profileCard.name, equals('Kasir Baru'));
      expect(viewModel.state.profile.successMessage, isNotEmpty);
      expect(remote.lastProfileSettingsInput?.name, equals('Kasir Baru'));
      expect(local.storedConfig.profile.name, equals('Kasir Baru'));
    });

    test('perubahan notifikasi langsung persist ke lokal', () async {
      viewModel.setPushNotification(false);
      viewModel.setTransactionSound(false);
      await Future<void>.delayed(Duration.zero);

      expect(local.storedConfig.notifications.pushNotification, isFalse);
      expect(local.storedConfig.notifications.transactionSound, isFalse);
    });

    test('onUpdateSecurity memvalidasi panjang pin dan kecocokan konfirmasi',
        () async {
      viewModel.setSecurityOldPin('123');
      viewModel.setSecurityNewPin('654321');
      viewModel.setSecurityConfirmPin('654321');

      final invalidLengthResult = await viewModel.onUpdateSecurity();
      expect(invalidLengthResult, isFalse);
      expect(
        viewModel.state.security.errorMessage,
        equals('PIN harus terdiri dari 6 digit angka'),
      );

      viewModel.setSecurityOldPin('123456');
      viewModel.setSecurityNewPin('654321');
      viewModel.setSecurityConfirmPin('111111');

      final mismatchResult = await viewModel.onUpdateSecurity();
      expect(mismatchResult, isFalse);
      expect(
        viewModel.state.security.errorMessage,
        equals('PIN baru dan konfirmasi PIN harus sama'),
      );

      viewModel.setSecurityConfirmPin('654321');
      final successResult = await viewModel.onUpdateSecurity();

      expect(successResult, isTrue);
      expect(viewModel.state.security.oldPin, isEmpty);
      expect(viewModel.state.security.successMessage, isNotEmpty);
      expect(remote.lastSecuritySettingsInput?.newPin, equals('654321'));
      expect(local.storedConfig.security.newPin, isEmpty);
    });

    test('setFaqExpanded hanya membuka satu item faq pada satu waktu', () {
      viewModel.setFaqExpanded(1, true);

      expect(viewModel.state.help.faqs[1].isExpanded, isTrue);
      expect(viewModel.state.help.faqs[0].isExpanded, isFalse);

      viewModel.setFaqExpanded(2, true);

      expect(viewModel.state.help.faqs[2].isExpanded, isTrue);
      expect(viewModel.state.help.faqs[1].isExpanded, isFalse);
    });

    test('setPrinterPaperWidth melakukan sync config ke printer service', () {
      viewModel.setPrinterPaperWidth('58mm');

      expect(printerService.lastConfig?.paperWidth, equals('58mm'));
      expect(printerService.syncConfigCallCount, greaterThanOrEqualTo(1));
    });
  });
}
