import 'package:flutter_test/flutter_test.dart';
import 'package:setting/data/seeders/setting_local.seeder.dart';

void main() {
  group('SettingLocalSeeder', () {
    test('buildInitialConfig menghasilkan seed default yang lengkap', () {
      final seed = const SettingLocalSeeder().buildInitialConfig();

      expect(seed.store.storeName, equals('SB Coffee'));
      expect(seed.store.branch, equals('Jakarta Selatan'));
      expect(seed.printer.devices.length, equals(1));
      expect(seed.printer.devices.first.isConnected, isTrue);
      expect(seed.paymentMethods.length, equals(5));
      expect(seed.profile.employeeId, equals('EMP-2023-001'));
      expect(seed.notifications.pushNotification, isTrue);
      expect(seed.security.oldPin, isEmpty);
      expect(seed.versionLabel, equals('SBPOS App v2'));
    });
  });
}
