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

part 'setting/setting_store.vm.dart';
part 'setting/setting_printer.vm.dart';
part 'setting/setting_payment.vm.dart';
part 'setting/setting_profile.vm.dart';
part 'setting/setting_notification.vm.dart';
part 'setting/setting_security.vm.dart';
part 'setting/setting_help.vm.dart';

abstract class _SettingViewModelScope {
  SettingState get state;

  set state(SettingState value);

  UpdateStoreInfo get _updateStoreInfo;

  UpdatePrinterSettings get _updatePrinterSettings;

  UpdatePaymentMethods get _updatePaymentMethods;

  UpdateProfileSettings get _updateProfileSettings;

  UpdateNotificationPreferences get _updateNotificationPreferences;

  UpdateSecuritySettings get _updateSecuritySettings;

  ReceiptPrinterService get _receiptPrinterService;

  StoreInfoState _mapStoreEntityToState(StoreInfoEntity store);

  PrinterSettingsState _mapPrinterEntityToState(PrinterSettingsEntity printer);

  ProfileFormState _mapProfileEntityToState(ProfileSettingsEntity profile);

  NotificationPreferencesState _mapNotificationEntityToState(
    NotificationPreferencesEntity notification,
  );

  PrinterSettingsEntity _buildPrinterEntity();

  Future<void> _syncPrinterServiceFromState();
}

class _SettingViewModelBase extends StateNotifier<SettingState>
    implements _SettingViewModelScope {
  _SettingViewModelBase({
    required GetSettingConfig getSettingConfig,
    required UpdateStoreInfo updateStoreInfo,
    required UpdatePrinterSettings updatePrinterSettings,
    required UpdatePaymentMethods updatePaymentMethods,
    required UpdateProfileSettings updateProfileSettings,
    required UpdateNotificationPreferences updateNotificationPreferences,
    required UpdateSecuritySettings updateSecuritySettings,
    required ReceiptPrinterService receiptPrinterService,
  })  : _getSettingConfig = getSettingConfig,
        _updateStoreInfo = updateStoreInfo,
        _updatePrinterSettings = updatePrinterSettings,
        _updatePaymentMethods = updatePaymentMethods,
        _updateProfileSettings = updateProfileSettings,
        _updateNotificationPreferences = updateNotificationPreferences,
        _updateSecuritySettings = updateSecuritySettings,
        _receiptPrinterService = receiptPrinterService,
        super(const SettingState.initial());

  final GetSettingConfig _getSettingConfig;

  @override
  final UpdateStoreInfo _updateStoreInfo;

  @override
  final UpdatePrinterSettings _updatePrinterSettings;

  @override
  final UpdatePaymentMethods _updatePaymentMethods;

  @override
  final UpdateProfileSettings _updateProfileSettings;

  @override
  final UpdateNotificationPreferences _updateNotificationPreferences;

  @override
  final UpdateSecuritySettings _updateSecuritySettings;

  @override
  final ReceiptPrinterService _receiptPrinterService;

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

  @override
  StoreInfoState _mapStoreEntityToState(StoreInfoEntity store) {
    return state.store.copyWith(
      storeName: store.storeName,
      branch: store.branch,
      address: store.address,
      phone: store.phone,
    );
  }

  @override
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

  @override
  ProfileFormState _mapProfileEntityToState(ProfileSettingsEntity profile) {
    return state.profile.copyWith(
      name: profile.name,
      employeeId: profile.employeeId,
      email: profile.email,
      phone: profile.phone,
    );
  }

  @override
  NotificationPreferencesState _mapNotificationEntityToState(
    NotificationPreferencesEntity notification,
  ) {
    return state.notification.copyWith(
      pushNotification: notification.pushNotification,
      transactionSound: notification.transactionSound,
      stockAlert: notification.stockAlert,
    );
  }

  @override
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

  @override
  Future<void> _syncPrinterServiceFromState() async {
    final connectedDevice = state.printer.devices.cast<PrinterDeviceState?>().firstWhere(
          (device) => device?.isConnected == true,
          orElse: () => null,
        );

    await _receiptPrinterService.syncConfig(
      ReceiptPrinterConfig(
        autoPrint: state.printer.autoPrint,
        printLogo: state.printer.printLogo,
        paperWidth: state.printer.paperWidth,
        printerName: connectedDevice?.name,
        isConnected: connectedDevice != null,
      ),
    );
  }
}

class SettingViewModel extends _SettingViewModelBase
    with
        _SettingStoreViewModelMixin,
        _SettingPrinterViewModelMixin,
        _SettingPaymentViewModelMixin,
        _SettingProfileViewModelMixin,
        _SettingNotificationViewModelMixin,
        _SettingSecurityViewModelMixin,
        _SettingHelpViewModelMixin {
  SettingViewModel({
    required super.getSettingConfig,
    required super.updateStoreInfo,
    required super.updatePrinterSettings,
    required super.updatePaymentMethods,
    required super.updateProfileSettings,
    required super.updateNotificationPreferences,
    required super.updateSecuritySettings,
    required super.receiptPrinterService,
  });
}
