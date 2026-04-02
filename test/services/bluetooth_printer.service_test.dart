import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:setting/data/models/setting_config.model.dart';
import 'package:setting/data/services/bluetooth_printer.facade.dart';

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
  int disconnectCallCount = 0;
  int printCallCount = 0;
  String? lastPrinterName;
  String? lastPaperWidth;
  String? lastPayload;

  @override
  Future<void> connect({
    required String printerName,
    required String paperWidth,
  }) async {
    connectCallCount += 1;
    lastPrinterName = printerName;
    lastPaperWidth = paperWidth;
  }

  @override
  Future<void> disconnect() async {
    disconnectCallCount += 1;
  }

  @override
  Future<void> print({
    required String printerName,
    required String paperWidth,
    required String payload,
  }) async {
    printCallCount += 1;
    lastPrinterName = printerName;
    lastPaperWidth = paperWidth;
    lastPayload = payload;
  }
}

SettingConfigModel _buildSettingConfig({
  required bool isConnected,
  String printerName = 'Epson TM-T82',
  String paperWidth = '58mm',
  bool printLogo = true,
}) {
  return SettingConfigModel(
    store: const StoreInfoModel(
      storeName: 'SB Coffee',
      branch: 'Makassar',
      address: 'Jl. Boulevard',
      phone: '08123456789',
    ),
    printer: PrinterSettingsModel(
      autoPrint: true,
      printLogo: printLogo,
      paperWidth: paperWidth,
      devices: [
        PrinterDeviceModel(
          name: printerName,
          subtitle: isConnected ? 'Terhubung' : 'Standby',
          isConnected: isConnected,
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
  group('BluetoothPrinterFacade', () {
    test(
      'bootstrap loads printer config from local DB and test print works without manual sync',
      () async {
        final local = _FakeSettingLocalDataSource(
          _buildSettingConfig(isConnected: true),
        );
        final client = _FakeBluetoothPrinterClient();
        final service = BluetoothPrinterFacade(
          localDataSource: local,
          client: client,
        );

        await service.bootstrap();
        final result = await service.printTestReceipt();

        expect(local.getCallCount, equals(1));
        expect(result.isSuccess, isTrue);
        expect(client.lastPrinterName, equals('Epson TM-T82'));
        expect(client.lastPaperWidth, equals('58mm'));
        expect(client.printCallCount, equals(1));
        expect(client.lastPayload, contains('SB POS'));
        expect(client.lastPayload, contains('TEST PRINTER BERHASIL'));
      },
    );

    test('printReceipt fails when bootstrapped config has no connected printer',
        () async {
      final local = _FakeSettingLocalDataSource(
        _buildSettingConfig(isConnected: false),
      );
      final client = _FakeBluetoothPrinterClient();
      final service = BluetoothPrinterFacade(
        localDataSource: local,
        client: client,
      );

      await service.bootstrap();
      final result = await service.printReceipt(
        const ReceiptPrintJob(
          title: 'SB POS',
          lines: [
            ReceiptPrintLine(label: 'Total', value: 'Rp 10.000'),
          ],
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(result.message, equals('Printer bluetooth belum terhubung'));
      expect(client.printCallCount, equals(0));
      expect(client.disconnectCallCount, greaterThanOrEqualTo(1));
    });

    test('syncConfig updates printer target and payload respects printLogo',
        () async {
      final local = _FakeSettingLocalDataSource(
        _buildSettingConfig(isConnected: false),
      );
      final client = _FakeBluetoothPrinterClient();
      final service = BluetoothPrinterFacade(
        localDataSource: local,
        client: client,
      );

      await service.bootstrap();
      await service.syncConfig(
        const ReceiptPrinterConfig(
          autoPrint: false,
          printLogo: false,
          paperWidth: '80mm',
          printerName: 'Kasir Bluetooth',
          isConnected: true,
        ),
      );

      final result = await service.printReceipt(
        const ReceiptPrintJob(
          title: 'SB POS',
          lines: [
            ReceiptPrintLine(label: 'No. Order', value: '#001'),
          ],
          footer: 'Terima kasih',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(client.lastPrinterName, equals('Kasir Bluetooth'));
      expect(client.lastPaperWidth, equals('80mm'));
      expect(client.lastPayload, isNot(contains('[LOGO]')));
      expect(client.lastPayload, contains('No. Order : #001'));
      expect(client.lastPayload, contains('Terima kasih'));
    });
  });
}
