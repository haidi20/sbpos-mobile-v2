import 'package:setting/data/models/setting_config.model.dart';

class SettingLocalSeeder {
  const SettingLocalSeeder();

  SettingConfigModel buildInitialConfig() {
    return const SettingConfigModel(
      store: StoreInfoModel(
        storeName: 'SB Coffee',
        branch: 'Jakarta Selatan',
        address: 'Jl. Sudirman No. 45, SCBD, Jakarta Selatan',
        phone: '0812-3456-7890',
      ),
      printer: PrinterSettingsModel(
        autoPrint: true,
        printLogo: true,
        paperWidth: '80mm',
        devices: [
          PrinterDeviceModel(
            name: 'Epson TM-T82',
            subtitle: 'Terhubung',
            isConnected: true,
          ),
        ],
      ),
      paymentMethods: [
        PaymentMethodModel(id: 1, name: 'Tunai (Cash)', isActive: true),
        PaymentMethodModel(id: 2, name: 'QRIS', isActive: true),
        PaymentMethodModel(id: 3, name: 'Kartu Debit', isActive: true),
        PaymentMethodModel(id: 4, name: 'Kartu Kredit', isActive: false),
        PaymentMethodModel(id: 5, name: 'Transfer Bank', isActive: false),
      ],
      profile: ProfileSettingsModel(
        name: 'Budi Santoso',
        employeeId: 'EMP-2023-001',
        email: 'budi@sbpos.com',
        phone: '0812-9999-8888',
      ),
      notifications: NotificationPreferencesModel(
        pushNotification: true,
        transactionSound: true,
        stockAlert: true,
      ),
      security: SecuritySettingsModel(
        oldPin: '',
        newPin: '',
        confirmPin: '',
      ),
      versionLabel: 'SBPOS App v2',
    );
  }
}
