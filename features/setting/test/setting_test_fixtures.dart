import 'package:core/core.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:setting/data/datasources/setting_remote.data_source.dart';
import 'package:setting/data/models/setting_config.model.dart';
import 'package:setting/data/seeders/setting_local.seeder.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';

StoreInfoEntity buildStoreInfoEntity() {
  return const StoreInfoEntity(
    storeName: 'SB Coffee Samarinda',
    branch: 'Samarinda Ulu',
    address: 'Jl. KH Wahid Hasyim No. 10',
    phone: '081211112222',
  );
}

PrinterSettingsEntity buildPrinterSettingsEntity() {
  return const PrinterSettingsEntity(
    autoPrint: true,
    printLogo: true,
    paperWidth: '58mm',
    devices: [
      PrinterDeviceEntity(
        name: 'Epson TM-T82',
        subtitle: 'Terhubung',
        isConnected: true,
      ),
      PrinterDeviceEntity(
        name: 'Bluetooth Printer 2',
        subtitle: 'Standby',
        isConnected: false,
      ),
    ],
  );
}

List<PaymentMethodEntity> buildPaymentMethodEntities() {
  return const [
    PaymentMethodEntity(id: 1, name: 'Tunai (Cash)', isActive: true),
    PaymentMethodEntity(id: 2, name: 'QRIS', isActive: true),
    PaymentMethodEntity(id: 3, name: 'Kartu Debit', isActive: true),
    PaymentMethodEntity(id: 4, name: 'Kartu Kredit', isActive: false),
    PaymentMethodEntity(id: 5, name: 'Transfer Bank', isActive: false),
  ];
}

ProfileSettingsEntity buildProfileSettingsEntity() {
  return const ProfileSettingsEntity(
    name: 'Sinta Dewi',
    employeeId: 'EMP-2026-002',
    email: 'sinta@sbpos.com',
    phone: '081300000000',
  );
}

NotificationPreferencesEntity buildNotificationPreferencesEntity() {
  return const NotificationPreferencesEntity(
    pushNotification: true,
    transactionSound: true,
    stockAlert: true,
  );
}

SecuritySettingsEntity buildSecuritySettingsEntity() {
  return const SecuritySettingsEntity(
    oldPin: '111111',
    newPin: '222222',
    confirmPin: '222222',
  );
}

SettingConfigEntity buildSettingConfigEntity() {
  return SettingConfigEntity(
    store: buildStoreInfoEntity(),
    printer: buildPrinterSettingsEntity(),
    paymentMethods: buildPaymentMethodEntities(),
    profile: buildProfileSettingsEntity(),
    notifications: buildNotificationPreferencesEntity(),
    security: const SecuritySettingsEntity(
      oldPin: '',
      newPin: '',
      confirmPin: '',
    ),
    versionLabel: 'SBPOS App v2.1.0',
  );
}

StoreInfoModel buildStoreInfoModel() {
  return StoreInfoModel.fromEntity(buildStoreInfoEntity());
}

PrinterSettingsModel buildPrinterSettingsModel() {
  return PrinterSettingsModel.fromEntity(buildPrinterSettingsEntity());
}

List<PaymentMethodModel> buildPaymentMethodModels() {
  return buildPaymentMethodEntities()
      .map(PaymentMethodModel.fromEntity)
      .toList();
}

ProfileSettingsModel buildProfileSettingsModel() {
  return ProfileSettingsModel.fromEntity(buildProfileSettingsEntity());
}

NotificationPreferencesModel buildNotificationPreferencesModel() {
  return NotificationPreferencesModel.fromEntity(
    buildNotificationPreferencesEntity(),
  );
}

SecuritySettingsModel buildSecuritySettingsModel() {
  return SecuritySettingsModel.fromEntity(buildSecuritySettingsEntity());
}

SettingConfigModel buildSettingConfigModel() {
  return SettingConfigModel.fromEntity(buildSettingConfigEntity());
}

class FakeSettingRemoteDataSource implements SettingRemoteDataSource {
  SettingConfigModel settingConfigResponse = buildSettingConfigModel();
  StoreInfoModel storeInfoResponse = buildStoreInfoModel();
  PrinterSettingsModel printerSettingsResponse = buildPrinterSettingsModel();
  List<PaymentMethodModel> paymentMethodsResponse = buildPaymentMethodModels();
  ProfileSettingsModel profileSettingsResponse = buildProfileSettingsModel();
  NotificationPreferencesModel notificationPreferencesResponse =
      buildNotificationPreferencesModel();
  bool securitySettingsResponse = true;

  Object? getSettingConfigError;
  Object? updateStoreInfoError;
  Object? updatePrinterSettingsError;
  Object? updatePaymentMethodsError;
  Object? updateProfileSettingsError;
  Object? updateNotificationPreferencesError;
  Object? updateSecuritySettingsError;

  StoreInfoModel? lastStoreInfoInput;
  PrinterSettingsModel? lastPrinterSettingsInput;
  List<PaymentMethodModel>? lastPaymentMethodsInput;
  ProfileSettingsModel? lastProfileSettingsInput;
  NotificationPreferencesModel? lastNotificationPreferencesInput;
  SecuritySettingsModel? lastSecuritySettingsInput;

  @override
  Future<SettingConfigModel> getSettingConfig() async {
    if (getSettingConfigError != null) {
      throw getSettingConfigError!;
    }
    return settingConfigResponse;
  }

  @override
  Future<StoreInfoModel> updateStoreInfo(StoreInfoModel storeInfo) async {
    if (updateStoreInfoError != null) {
      throw updateStoreInfoError!;
    }
    lastStoreInfoInput = storeInfo;
    storeInfoResponse = storeInfo;
    return storeInfoResponse;
  }

  @override
  Future<PrinterSettingsModel> updatePrinterSettings(
    PrinterSettingsModel printerSettings,
  ) async {
    if (updatePrinterSettingsError != null) {
      throw updatePrinterSettingsError!;
    }
    lastPrinterSettingsInput = printerSettings;
    printerSettingsResponse = printerSettings;
    return printerSettingsResponse;
  }

  @override
  Future<List<PaymentMethodModel>> updatePaymentMethods(
    List<PaymentMethodModel> paymentMethods,
  ) async {
    if (updatePaymentMethodsError != null) {
      throw updatePaymentMethodsError!;
    }
    lastPaymentMethodsInput = paymentMethods;
    paymentMethodsResponse = paymentMethods;
    return paymentMethodsResponse;
  }

  @override
  Future<ProfileSettingsModel> updateProfileSettings(
    ProfileSettingsModel profileSettings,
  ) async {
    if (updateProfileSettingsError != null) {
      throw updateProfileSettingsError!;
    }
    lastProfileSettingsInput = profileSettings;
    profileSettingsResponse = profileSettings;
    return profileSettingsResponse;
  }

  @override
  Future<NotificationPreferencesModel> updateNotificationPreferences(
    NotificationPreferencesModel notificationPreferences,
  ) async {
    if (updateNotificationPreferencesError != null) {
      throw updateNotificationPreferencesError!;
    }
    lastNotificationPreferencesInput = notificationPreferences;
    notificationPreferencesResponse = notificationPreferences;
    return notificationPreferencesResponse;
  }

  @override
  Future<bool> updateSecuritySettings(
    SecuritySettingsModel securitySettings,
  ) async {
    if (updateSecuritySettingsError != null) {
      throw updateSecuritySettingsError!;
    }
    lastSecuritySettingsInput = securitySettings;
    return securitySettingsResponse;
  }
}

class FakeSettingLocalDataSource extends SettingLocalDataSource {
  FakeSettingLocalDataSource({
    SettingConfigModel? initialConfig,
  })  : storedConfig = initialConfig ?? buildSettingConfigModel(),
        super();

  SettingConfigModel storedConfig;
  int getCallCount = 0;
  int saveCallCount = 0;
  int clearCallCount = 0;

  @override
  Future<SettingConfigModel> getSettingConfig() async {
    getCallCount += 1;
    return storedConfig;
  }

  @override
  Future<SettingConfigModel> saveSettingConfig(SettingConfigModel config) async {
    saveCallCount += 1;
    storedConfig = config;
    return storedConfig;
  }

  @override
  Future<int> clearSettings() async {
    clearCallCount += 1;
    storedConfig = const SettingLocalSeeder().buildInitialConfig();
    return 1;
  }
}

class FakeReceiptPrinterService implements ReceiptPrinterService {
  ReceiptPrinterConfig? lastConfig;
  ReceiptPrintJob? lastJob;
  ReceiptPrintResult testPrintResult = const ReceiptPrintResult.success(
    'Test print berhasil',
  );
  ReceiptPrintResult receiptPrintResult = const ReceiptPrintResult.success(
    'Struk berhasil dicetak',
  );
  int syncConfigCallCount = 0;
  int testPrintCallCount = 0;
  int receiptPrintCallCount = 0;

  @override
  Future<ReceiptPrintResult> printReceipt(ReceiptPrintJob job) async {
    lastJob = job;
    receiptPrintCallCount += 1;
    return receiptPrintResult;
  }

  @override
  Future<ReceiptPrintResult> printTestReceipt() async {
    testPrintCallCount += 1;
    return testPrintResult;
  }

  @override
  Future<void> syncConfig(ReceiptPrinterConfig config) async {
    lastConfig = config;
    syncConfigCallCount += 1;
  }
}
