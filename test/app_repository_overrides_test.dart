import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbpos_v2/app_repository_overrides.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:setting/data/models/setting_config.model.dart';
import 'package:setting/data/services/bluetooth_printer.facade.dart';
import 'package:setting/presentation/providers/setting.provider.dart';

class _FakeSettingLocalDataSource extends SettingLocalDataSource {
  _FakeSettingLocalDataSource(this.config);

  final SettingConfigModel config;
  int getCallCount = 0;

  @override
  Future<SettingConfigModel> getSettingConfig() async {
    getCallCount += 1;
    return config;
  }
}

class _FakeBluetoothPrinterClient implements BluetoothPrinterClient {
  int connectCallCount = 0;
  int printCallCount = 0;
  String? lastPrinterName;

  @override
  Future<void> connect({
    required String printerName,
    required String paperWidth,
  }) async {
    connectCallCount += 1;
    lastPrinterName = printerName;
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> print({
    required String printerName,
    required String paperWidth,
    required String payload,
  }) async {
    printCallCount += 1;
    lastPrinterName = printerName;
  }
}

SettingConfigModel _buildSettingConfig() {
  return SettingConfigModel(
    store: const StoreInfoModel(
      storeName: 'SB Coffee',
      branch: 'Makassar',
      address: 'Jl. Boulevard',
      phone: '08123456789',
    ),
    printer: const PrinterSettingsModel(
      autoPrint: true,
      printLogo: true,
      paperWidth: '58mm',
      devices: [
        PrinterDeviceModel(
          name: 'Boot Printer',
          subtitle: 'Terhubung',
          isConnected: true,
        ),
      ],
    ),
    paymentMethods: const [
      PaymentMethodModel(id: 1, name: 'Tunai', isActive: true),
    ],
    profile: const ProfileSettingsModel(
      name: 'Kasir',
      employeeId: 'EMP-1',
      email: 'kasir@sbpos.test',
      phone: '081111111111',
    ),
    notifications: const NotificationPreferencesModel(
      pushNotification: true,
      transactionSound: true,
      stockAlert: true,
    ),
    security: const SecuritySettingsModel(
      oldPin: '',
      newPin: '',
      confirmPin: '',
    ),
    versionLabel: 'SBPOS App v2',
  );
}

void main() {
  test(
    'buildAppRepositoryOverrides wires bootstrapped printer service and shared setting local datasource',
    () async {
      final local = _FakeSettingLocalDataSource(_buildSettingConfig());
      final client = _FakeBluetoothPrinterClient();

      final overrides = await buildAppRepositoryOverrides(
        settingLocalDataSource: local,
        bluetoothPrinterClient: client,
      );

      final container = ProviderContainer(overrides: overrides);
      addTearDown(container.dispose);

      final injectedLocal = container.read(settingLocalDataSourceProvider);
      final service = container.read(printerFacadeProvider);
      final result = await service.printTestReceipt();

      expect(identical(injectedLocal, local), isTrue);
      expect(local.getCallCount, equals(1));
      expect(result.isSuccess, isTrue);
      expect(client.lastPrinterName, equals('Boot Printer'));
      expect(client.printCallCount, equals(1));
    },
  );
}
