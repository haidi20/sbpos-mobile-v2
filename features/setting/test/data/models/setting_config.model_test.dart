import 'package:flutter_test/flutter_test.dart';
import 'package:setting/data/models/setting_config.model.dart';

import 'package:setting/testing/setting_test_fixtures.dart';

void main() {
  group('Setting models', () {
    test('StoreInfoModel fromJson dan toEntity sesuai contract', () {
      final model = StoreInfoModel.fromJson(const {
        'store_name': 'SB Coffee Samarinda',
        'branch': 'Samarinda Ulu',
        'address': 'Jl. KH Wahid Hasyim No. 10',
        'phone': '081211112222',
      });

      final entity = model.toEntity();

      expect(entity.storeName, equals('SB Coffee Samarinda'));
      expect(entity.branch, equals('Samarinda Ulu'));
      expect(entity.address, equals('Jl. KH Wahid Hasyim No. 10'));
      expect(entity.phone, equals('081211112222'));
    });

    test('StoreInfoModel fromEntity menghasilkan payload json yang benar', () {
      final model = StoreInfoModel.fromEntity(buildStoreInfoEntity());

      expect(model.toJson(), {
        'store_name': 'SB Coffee Samarinda',
        'branch': 'Samarinda Ulu',
        'address': 'Jl. KH Wahid Hasyim No. 10',
        'phone': '081211112222',
      });
    });

    test('PrinterDeviceModel fromEntity dan toJson sesuai', () {
      final model = PrinterDeviceModel.fromEntity(
        buildPrinterSettingsEntity().devices.first,
      );

      expect(model.toJson(), {
        'name': 'Epson TM-T82',
        'subtitle': 'Terhubung',
        'is_connected': true,
      });
    });

    test('PrinterSettingsModel fromJson membangun list devices', () {
      final model = PrinterSettingsModel.fromJson(const {
        'auto_print': false,
        'print_logo': true,
        'paper_width': '58mm',
        'devices': [
          {
            'name': 'Epson TM-T82',
            'subtitle': 'Terhubung',
            'is_connected': true,
          },
          {
            'name': 'Bluetooth Printer 2',
            'subtitle': 'Standby',
            'is_connected': false,
          },
        ],
      });

      expect(model.autoPrint, isFalse);
      expect(model.printLogo, isTrue);
      expect(model.paperWidth, equals('58mm'));
      expect(model.devices.length, equals(2));
      expect(model.devices.last.isConnected, isFalse);
    });

    test('PaymentMethodModel fromJson dan toEntity sesuai', () {
      final model = PaymentMethodModel.fromJson(const {
        'id': 5,
        'name': 'Transfer Bank',
        'is_active': false,
      });

      final entity = model.toEntity();

      expect(entity.id, equals(5));
      expect(entity.name, equals('Transfer Bank'));
      expect(entity.isActive, isFalse);
    });

    test('ProfileSettingsModel fromEntity menghasilkan payload benar', () {
      final model = ProfileSettingsModel.fromEntity(buildProfileSettingsEntity());

      expect(model.toJson(), {
        'name': 'Sinta Dewi',
        'employee_id': 'EMP-2026-002',
        'email': 'sinta@sbpos.com',
        'phone': '081300000000',
      });
    });

    test('NotificationPreferencesModel fromJson sesuai contract', () {
      final model = NotificationPreferencesModel.fromJson(const {
        'push_notification': true,
        'transaction_sound': true,
        'stock_alert': true,
      });

      final entity = model.toEntity();

      expect(entity.pushNotification, isTrue);
      expect(entity.transactionSound, isTrue);
      expect(entity.stockAlert, isTrue);
    });

    test('SecuritySettingsModel fromEntity menghasilkan payload benar', () {
      final model = SecuritySettingsModel.fromEntity(buildSecuritySettingsEntity());

      expect(model.toJson(), {
        'old_pin': '111111',
        'new_pin': '222222',
        'confirm_pin': '222222',
      });
    });

    test('SettingConfigModel fromEntity menjaga nested object', () {
      final model = SettingConfigModel.fromEntity(buildSettingConfigEntity());

      expect(model.store.storeName, equals('SB Coffee Samarinda'));
      expect(model.printer.devices.length, equals(2));
      expect(model.paymentMethods.length, equals(5));
      expect(model.profile.employeeId, equals('EMP-2026-002'));
      expect(model.notifications.transactionSound, isTrue);
      expect(model.security.confirmPin, isEmpty);
      expect(model.versionLabel, equals('SBPOS App v2.1.0'));
    });

    test('SettingConfigModel fromJson dan toEntity sesuai contract agregat', () {
      final model = SettingConfigModel.fromJson({
        'store': buildStoreInfoModel().toJson(),
        'printer': buildPrinterSettingsModel().toJson(),
        'payment_methods': buildPaymentMethodModels()
            .map((item) => item.toJson())
            .toList(),
        'profile': buildProfileSettingsModel().toJson(),
        'notifications': buildNotificationPreferencesModel().toJson(),
        'security': buildSecuritySettingsModel().toJson(),
        'version_label': 'SBPOS App v2.1.0',
      });

      final entity = model.toEntity();

      expect(entity.store.branch, equals('Samarinda Ulu'));
      expect(entity.printer.paperWidth, equals('58mm'));
      expect(entity.paymentMethods.last.name, equals('Transfer Bank'));
      expect(entity.profile.name, equals('Sinta Dewi'));
      expect(entity.notifications.stockAlert, isTrue);
      expect(entity.security.newPin, equals('222222'));
      expect(entity.versionLabel, equals('SBPOS App v2.1.0'));
    });

    test('SettingConfigModel toDbLocal dan fromDbLocal menjaga aggregate', () {
      final model = buildSettingConfigModel();

      final dbMap = model.toDbLocal();
      final restored = SettingConfigModel.fromDbLocal(dbMap);

      expect(restored.store.phone, equals('081211112222'));
      expect(restored.printer.devices.first.name, equals('Epson TM-T82'));
      expect(restored.paymentMethods.length, equals(5));
      expect(restored.notifications.pushNotification, isTrue);
      expect(restored.security.confirmPin, isEmpty);
    });
  });
}
