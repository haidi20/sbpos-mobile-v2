import 'package:core/core.dart';
import 'package:setting/data/datasources/db/setting_database_schema.dart';
import 'package:setting/data/datasources/setting_remote.data_source.dart';
import 'package:setting/data/models/setting_config.model.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/routes/setting_preview_router.dart';

void main() {
  configureSettingDatabaseSchema();
  runApp(
    ProviderScope(
      overrides: [
        settingRemoteDataSourceProvider.overrideWithValue(
          _PreviewSettingRemoteDataSource(),
        ),
        printerFacadeProvider.overrideWithValue(
          _PreviewPrinterFacade(),
        ),
      ],
      child: const SettingPreviewApp(),
    ),
  );
}

class SettingPreviewApp extends StatelessWidget {
  const SettingPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Setting Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppSetting.primaryColor),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: settingPreviewRouter,
    );
  }
}

class _PreviewSettingRemoteDataSource implements SettingRemoteDataSource {
  SettingConfigModel _config = SettingConfigModel.fromJson(const {
    'store': {
      'store_name': 'SB Coffee',
      'branch': 'Jakarta Selatan',
      'address': 'Jl. Sudirman No. 45, SCBD, Jakarta Selatan',
      'phone': '0812-3456-7890',
    },
    'printer': {
      'auto_print': true,
      'print_logo': true,
      'paper_width': '80mm',
      'devices': [
        {
          'name': 'Epson TM-T82',
          'subtitle': 'Terhubung',
          'is_connected': true,
        },
      ],
    },
    'payment_methods': [
      {'id': 1, 'name': 'Tunai (Cash)', 'is_active': true},
      {'id': 2, 'name': 'QRIS', 'is_active': true},
      {'id': 3, 'name': 'Kartu Debit', 'is_active': true},
      {'id': 4, 'name': 'Kartu Kredit', 'is_active': false},
      {'id': 5, 'name': 'Transfer Bank', 'is_active': false},
    ],
    'profile': {
      'name': 'Budi Santoso',
      'employee_id': 'EMP-2023-001',
      'email': 'budi@sbpos.com',
      'phone': '0812-9999-8888',
    },
    'notifications': {
      'push_notification': true,
      'transaction_sound': true,
      'stock_alert': true,
    },
    'security': {
      'old_pin': '',
      'new_pin': '',
      'confirm_pin': '',
    },
    'version_label': 'SBPOS App v2',
  });

  @override
  Future<SettingConfigModel> getSettingConfig() async => _config;

  @override
  Future<NotificationPreferencesModel> updateNotificationPreferences(
    NotificationPreferencesModel notificationPreferences,
  ) async {
    _config = SettingConfigModel(
      store: _config.store,
      printer: _config.printer,
      paymentMethods: _config.paymentMethods,
      profile: _config.profile,
      notifications: notificationPreferences,
      security: _config.security,
      versionLabel: _config.versionLabel,
    );
    return notificationPreferences;
  }

  @override
  Future<List<PaymentMethodModel>> updatePaymentMethods(
    List<PaymentMethodModel> paymentMethods,
  ) async {
    _config = SettingConfigModel(
      store: _config.store,
      printer: _config.printer,
      paymentMethods: paymentMethods,
      profile: _config.profile,
      notifications: _config.notifications,
      security: _config.security,
      versionLabel: _config.versionLabel,
    );
    return paymentMethods;
  }

  @override
  Future<PrinterSettingsModel> updatePrinterSettings(
    PrinterSettingsModel printerSettings,
  ) async {
    _config = SettingConfigModel(
      store: _config.store,
      printer: printerSettings,
      paymentMethods: _config.paymentMethods,
      profile: _config.profile,
      notifications: _config.notifications,
      security: _config.security,
      versionLabel: _config.versionLabel,
    );
    return printerSettings;
  }

  @override
  Future<ProfileSettingsModel> updateProfileSettings(
    ProfileSettingsModel profileSettings,
  ) async {
    _config = SettingConfigModel(
      store: _config.store,
      printer: _config.printer,
      paymentMethods: _config.paymentMethods,
      profile: profileSettings,
      notifications: _config.notifications,
      security: _config.security,
      versionLabel: _config.versionLabel,
    );
    return profileSettings;
  }

  @override
  Future<bool> updateSecuritySettings(
    SecuritySettingsModel securitySettings,
  ) async {
    return true;
  }

  @override
  Future<StoreInfoModel> updateStoreInfo(StoreInfoModel storeInfo) async {
    _config = SettingConfigModel(
      store: storeInfo,
      printer: _config.printer,
      paymentMethods: _config.paymentMethods,
      profile: _config.profile,
      notifications: _config.notifications,
      security: _config.security,
      versionLabel: _config.versionLabel,
    );
    return storeInfo;
  }
}

class _PreviewPrinterFacade implements PrinterFacade {
  ReceiptPrinterConfig? _config;

  @override
  Future<ReceiptPrintResult> printReceipt(ReceiptPrintJob job) async {
    if (_config?.isConnected != true) {
      return const ReceiptPrintResult.failure('Printer belum terhubung');
    }

    return const ReceiptPrintResult.success('Struk berhasil dicetak');
  }

  @override
  Future<ReceiptPrintResult> printTestReceipt() async {
    if (_config?.isConnected != true) {
      return const ReceiptPrintResult.failure('Printer belum terhubung');
    }

    return const ReceiptPrintResult.success('Test print berhasil');
  }

  @override
  Future<void> syncConfig(ReceiptPrinterConfig config) async {
    _config = config;
  }
}
