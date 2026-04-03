import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/usecases/get_setting_config.usecase.dart';
import 'package:setting/domain/usecases/update_notification_preferences.usecase.dart';
import 'package:setting/domain/usecases/update_payment_methods.usecase.dart';
import 'package:setting/domain/usecases/update_printer_settings.usecase.dart';
import 'package:setting/domain/usecases/update_profile_settings.usecase.dart';
import 'package:setting/domain/usecases/update_security_settings.usecase.dart';
import 'package:setting/domain/usecases/update_store_info.usecase.dart';
import 'package:setting/presentation/view_models/setting.state.dart';
import 'package:setting/presentation/view_models/setting/setting_help.vm.dart';
import 'package:setting/presentation/view_models/setting/setting_notification.vm.dart';
import 'package:setting/presentation/view_models/setting/setting_payment.vm.dart';
import 'package:setting/presentation/view_models/setting/setting_printer.vm.dart';
import 'package:setting/presentation/view_models/setting/setting_profile.vm.dart';
import 'package:setting/presentation/view_models/setting/setting_security.vm.dart';
import 'package:setting/presentation/view_models/setting/setting_store.vm.dart';

class SettingViewModel extends StateNotifier<SettingState> {
  SettingViewModel({
    required GetSettingConfig getSettingConfig,
    required UpdateStoreInfo updateStoreInfo,
    required UpdatePrinterSettings updatePrinterSettings,
    required UpdatePaymentMethods updatePaymentMethods,
    required UpdateProfileSettings updateProfileSettings,
    required UpdateNotificationPreferences updateNotificationPreferences,
    required UpdateSecuritySettings updateSecuritySettings,
    required PrinterFacade printerFacade,
  })  : _getSettingConfig = getSettingConfig,
        _updateStoreInfo = updateStoreInfo,
        _updatePrinterSettings = updatePrinterSettings,
        _updatePaymentMethods = updatePaymentMethods,
        _updateProfileSettings = updateProfileSettings,
        _updateNotificationPreferences = updateNotificationPreferences,
        _updateSecuritySettings = updateSecuritySettings,
        _printerFacade = printerFacade,
        super(const SettingState.initial()) {
    _storeActions = SettingStoreViewModelActions(
      updateStoreInfo: _updateStoreInfo,
      getState: _getState,
      setState: _setState,
      mapStoreEntityToState: _mapStoreEntityToState,
    );
    _printerActions = SettingPrinterViewModelActions(
      updatePrinterSettings: _updatePrinterSettings,
      printerFacade: _printerFacade,
      getState: _getState,
      setState: _setState,
      mapPrinterEntityToState: _mapPrinterEntityToState,
      buildPrinterEntity: _buildPrinterEntity,
      syncPrinterServiceFromState: _syncPrinterServiceFromState,
    );
    _paymentActions = SettingPaymentViewModelActions(
      updatePaymentMethods: _updatePaymentMethods,
      getState: _getState,
      setState: _setState,
    );
    _profileActions = SettingProfileViewModelActions(
      updateProfileSettings: _updateProfileSettings,
      getState: _getState,
      setState: _setState,
      mapProfileEntityToState: _mapProfileEntityToState,
    );
    _notificationActions = SettingNotificationViewModelActions(
      updateNotificationPreferences: _updateNotificationPreferences,
      getState: _getState,
      setState: _setState,
      mapNotificationEntityToState: _mapNotificationEntityToState,
    );
    _securityActions = SettingSecurityViewModelActions(
      updateSecuritySettings: _updateSecuritySettings,
      getState: _getState,
      setState: _setState,
    );
    _helpActions = SettingHelpViewModelActions(
      getState: _getState,
      setState: _setState,
    );
  }

  final GetSettingConfig _getSettingConfig;
  final UpdateStoreInfo _updateStoreInfo;
  final UpdatePrinterSettings _updatePrinterSettings;
  final UpdatePaymentMethods _updatePaymentMethods;
  final UpdateProfileSettings _updateProfileSettings;
  final UpdateNotificationPreferences _updateNotificationPreferences;
  final UpdateSecuritySettings _updateSecuritySettings;
  final PrinterFacade _printerFacade;

  late final SettingStoreViewModelActions _storeActions;
  late final SettingPrinterViewModelActions _printerActions;
  late final SettingPaymentViewModelActions _paymentActions;
  late final SettingProfileViewModelActions _profileActions;
  late final SettingNotificationViewModelActions _notificationActions;
  late final SettingSecurityViewModelActions _securityActions;
  late final SettingHelpViewModelActions _helpActions;

  SettingState _getState() => state;

  void _setState(SettingState value) {
    state = value;
  }

  SettingProfileCardState get getProfileCard => state.profileCard;

  List<PaymentMethodState> get getPaymentMethods => state.payment.methods;

  List<PrinterDeviceState> get getPrinterDevices => state.printer.devices;

  List<FaqItemState> get getFaqItems => state.help.faqs;

  String get getStoreSummary => '${state.store.storeName} - ${state.store.branch}';

  String get getPrinterSummary {
    final connected = state.printer.devices.where((device) => device.isConnected);
    if (connected.isEmpty) {
      return 'Belum ada printer terhubung';
    }

    final device = connected.first;
    return '${device.name} (${device.subtitle})';
  }

  String get getPaymentSummary {
    final activeMethods = state.payment.methods
        .where((method) => method.isActive)
        .map((method) => method.name)
        .toList();

    if (activeMethods.isEmpty) {
      return 'Belum ada metode aktif';
    }

    return activeMethods.join(', ');
  }

  String get getNotificationSummary {
    final activeCount = [
      state.notification.pushNotification,
      state.notification.transactionSound,
      state.notification.stockAlert,
    ].where((value) => value).length;

    if (activeCount == 0) {
      return 'Semua notifikasi nonaktif';
    }

    if (activeCount == 3) {
      return 'Semua notifikasi aktif';
    }

    return '$activeCount preferensi aktif';
  }

  Future<void> getSettingConfig() async {
    final result = await _getSettingConfig();
    await result.fold(
      (failure) async {
        state = state.copyWith(
          printer: state.printer.copyWith(
            message: failure.message,
            isError: true,
          ),
        );
      },
      (config) async {
        state = state.copyWith(
          store: _mapStoreEntityToState(config.store),
          printer: _mapPrinterEntityToState(config.printer),
          payment: state.payment.copyWith(
            methods: config.paymentMethods
                .map(
                  (method) => PaymentMethodState(
                    id: method.id,
                    name: method.name,
                    isActive: method.isActive,
                  ),
                )
                .toList(),
          ),
          profile: _mapProfileEntityToState(config.profile),
          profileCard: state.profileCard.copyWith(name: config.profile.name),
          notification: _mapNotificationEntityToState(config.notifications),
          security: state.security.copyWith(
            oldPin: config.security.oldPin,
            newPin: config.security.newPin,
            confirmPin: config.security.confirmPin,
          ),
          versionLabel: config.versionLabel,
        );
        await _syncPrinterServiceFromState();
      },
    );
  }

  StoreInfoState _mapStoreEntityToState(StoreInfoEntity store) {
    return state.store.copyWith(
      storeName: store.storeName,
      branch: store.branch,
      address: store.address,
      phone: store.phone,
    );
  }

  PrinterSettingsState _mapPrinterEntityToState(PrinterSettingsEntity printer) {
    return state.printer.copyWith(
      autoPrint: printer.autoPrint,
      printLogo: printer.printLogo,
      paperWidth: printer.paperWidth,
      devices: printer.devices
          .map(
            (device) => PrinterDeviceState(
              name: device.name,
              subtitle: device.subtitle,
              isConnected: device.isConnected,
            ),
          )
          .toList(),
    );
  }

  ProfileFormState _mapProfileEntityToState(ProfileSettingsEntity profile) {
    return state.profile.copyWith(
      name: profile.name,
      employeeId: profile.employeeId,
      email: profile.email,
      phone: profile.phone,
    );
  }

  NotificationPreferencesState _mapNotificationEntityToState(
    NotificationPreferencesEntity notification,
  ) {
    return state.notification.copyWith(
      pushNotification: notification.pushNotification,
      transactionSound: notification.transactionSound,
      stockAlert: notification.stockAlert,
    );
  }

  PrinterSettingsEntity _buildPrinterEntity() {
    return PrinterSettingsEntity(
      autoPrint: state.printer.autoPrint,
      printLogo: state.printer.printLogo,
      paperWidth: state.printer.paperWidth,
      devices: state.printer.devices
          .map(
            (device) => PrinterDeviceEntity(
              name: device.name,
              subtitle: device.subtitle,
              isConnected: device.isConnected,
            ),
          )
          .toList(),
    );
  }

  Future<void> _syncPrinterServiceFromState() async {
    final connectedDevice = state.printer.devices.cast<PrinterDeviceState?>().firstWhere(
          (device) => device?.isConnected == true,
          orElse: () => null,
        );

    await _printerFacade.syncConfig(
      ReceiptPrinterConfig(
        autoPrint: state.printer.autoPrint,
        printLogo: state.printer.printLogo,
        paperWidth: state.printer.paperWidth,
        printerName: connectedDevice?.name,
        isConnected: connectedDevice != null,
      ),
    );
  }

  void setStoreName(String value) => _storeActions.setStoreName(value);

  void setStoreBranch(String value) => _storeActions.setStoreBranch(value);

  void setStoreAddress(String value) => _storeActions.setStoreAddress(value);

  void setStorePhone(String value) => _storeActions.setStorePhone(value);

  Future<bool> onSaveStoreInfo() => _storeActions.onSaveStoreInfo();

  void setPrinterAutoPrint(bool value) => _printerActions.setPrinterAutoPrint(value);

  void setPrinterPrintLogo(bool value) => _printerActions.setPrinterPrintLogo(value);

  void setPrinterPaperWidth(String value) => _printerActions.setPrinterPaperWidth(value);

  void setPrinterConnected(String deviceName, bool isConnected) =>
      _printerActions.setPrinterConnected(deviceName, isConnected);

  Future<bool> onTestPrint() => _printerActions.onTestPrint();

  void setPaymentMethodActive(int id, bool isActive) =>
      _paymentActions.setPaymentMethodActive(id, isActive);

  Future<bool> onSavePaymentMethods() => _paymentActions.onSavePaymentMethods();

  void setProfileName(String value) => _profileActions.setProfileName(value);

  void setProfileEmployeeId(String value) => _profileActions.setProfileEmployeeId(value);

  void setProfileEmail(String value) => _profileActions.setProfileEmail(value);

  void setProfilePhone(String value) => _profileActions.setProfilePhone(value);

  Future<bool> onSaveProfile() => _profileActions.onSaveProfile();

  void setPushNotification(bool value) => _notificationActions.setPushNotification(value);

  void setTransactionSound(bool value) => _notificationActions.setTransactionSound(value);

  void setStockAlert(bool value) => _notificationActions.setStockAlert(value);

  Future<bool> onSaveNotificationPreferences() =>
      _notificationActions.onSaveNotificationPreferences();

  void setSecurityOldPin(String value) => _securityActions.setSecurityOldPin(value);

  void setSecurityNewPin(String value) => _securityActions.setSecurityNewPin(value);

  void setSecurityConfirmPin(String value) =>
      _securityActions.setSecurityConfirmPin(value);

  Future<bool> onUpdateSecurity() => _securityActions.onUpdateSecurity();

  void setFaqExpanded(int index, bool isExpanded) =>
      _helpActions.setFaqExpanded(index, isExpanded);
}
