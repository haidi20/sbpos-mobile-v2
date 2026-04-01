import 'package:core/core.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:setting/data/datasources/setting_remote.data_source.dart';
import 'package:setting/data/repositories/setting.repository.impl.dart';
import 'package:setting/domain/repositories/setting.repository.dart';
import 'package:setting/domain/usecases/get_setting_config.usecase.dart';
import 'package:setting/domain/usecases/update_notification_preferences.usecase.dart';
import 'package:setting/domain/usecases/update_payment_methods.usecase.dart';
import 'package:setting/domain/usecases/update_printer_settings.usecase.dart';
import 'package:setting/domain/usecases/update_profile_settings.usecase.dart';
import 'package:setting/domain/usecases/update_security_settings.usecase.dart';
import 'package:setting/domain/usecases/update_store_info.usecase.dart';
import 'package:setting/presentation/view_models/setting.state.dart';
import 'package:setting/presentation/view_models/setting.vm.dart';

final settingRemoteDataSourceProvider = Provider<SettingRemoteDataSource?>(
  (ref) => null,
);

final settingLocalDataSourceProvider = Provider<SettingLocalDataSource>(
  (ref) => SettingLocalDataSource(),
);

final settingRepositoryProvider = Provider<SettingRepository?>(
  (ref) => SettingRepositoryImpl(
    remote: ref.watch(settingRemoteDataSourceProvider),
    local: ref.watch(settingLocalDataSourceProvider),
  ),
);

final getSettingConfigProvider = Provider(
  (ref) => GetSettingConfig(ref.watch(settingRepositoryProvider)!),
);

final updateStoreInfoProvider = Provider(
  (ref) => UpdateStoreInfo(ref.watch(settingRepositoryProvider)!),
);

final updatePrinterSettingsProvider = Provider(
  (ref) => UpdatePrinterSettings(ref.watch(settingRepositoryProvider)!),
);

final updatePaymentMethodsProvider = Provider(
  (ref) => UpdatePaymentMethods(ref.watch(settingRepositoryProvider)!),
);

final updateProfileSettingsProvider = Provider(
  (ref) => UpdateProfileSettings(ref.watch(settingRepositoryProvider)!),
);

final updateNotificationPreferencesProvider = Provider(
  (ref) => UpdateNotificationPreferences(ref.watch(settingRepositoryProvider)!),
);

final updateSecuritySettingsProvider = Provider(
  (ref) => UpdateSecuritySettings(ref.watch(settingRepositoryProvider)!),
);

final settingViewModelProvider =
    StateNotifierProvider<SettingViewModel, SettingState>(
  (ref) {
    final viewModel = SettingViewModel(
      getSettingConfig: ref.watch(getSettingConfigProvider),
      updateStoreInfo: ref.watch(updateStoreInfoProvider),
      updatePrinterSettings: ref.watch(updatePrinterSettingsProvider),
      updatePaymentMethods: ref.watch(updatePaymentMethodsProvider),
      updateProfileSettings: ref.watch(updateProfileSettingsProvider),
      updateNotificationPreferences:
          ref.watch(updateNotificationPreferencesProvider),
      updateSecuritySettings: ref.watch(updateSecuritySettingsProvider),
      receiptPrinterService: ref.watch(receiptPrinterServiceProvider),
    );
    unawaited(viewModel.getSettingConfig());
    return viewModel;
  },
);

final settingProfileCardStateProvider = Provider<SettingProfileCardState>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.profileCard),
  ),
);

final settingStoreStateProvider = Provider<StoreInfoState>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.store),
  ),
);

final settingPrinterStateProvider = Provider<PrinterSettingsState>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.printer),
  ),
);

final settingPaymentStateProvider = Provider<PaymentSettingsState>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.payment),
  ),
);

final settingProfileStateProvider = Provider<ProfileFormState>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.profile),
  ),
);

final settingNotificationStateProvider = Provider<NotificationPreferencesState>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.notification),
  ),
);

final settingSecurityStateProvider = Provider<SecurityFormState>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.security),
  ),
);

final settingHelpStateProvider = Provider<HelpState>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.help),
  ),
);

final settingVersionLabelProvider = Provider<String>(
  (ref) => ref.watch(
    settingViewModelProvider.select((state) => state.versionLabel),
  ),
);

final settingStoreSummaryProvider = Provider<String>(
  (ref) {
    final store = ref.watch(settingStoreStateProvider);
    return '${store.storeName} - ${store.branch}';
  },
);

final settingPrinterSummaryProvider = Provider<String>(
  (ref) {
    final printer = ref.watch(settingPrinterStateProvider);
    final connected = printer.devices.where((device) => device.isConnected);
    if (connected.isEmpty) {
      return 'Belum ada printer terhubung';
    }

    final device = connected.first;
    return '${device.name} (${device.subtitle})';
  },
);

final settingPaymentSummaryProvider = Provider<String>(
  (ref) {
    final payment = ref.watch(settingPaymentStateProvider);
    final activeMethods = payment.methods
        .where((method) => method.isActive)
        .map((method) => method.name)
        .toList();

    if (activeMethods.isEmpty) {
      return 'Belum ada metode aktif';
    }

    return activeMethods.join(', ');
  },
);

final settingNotificationSummaryProvider = Provider<String>(
  (ref) {
    final notification = ref.watch(settingNotificationStateProvider);
    final activeCount = [
      notification.pushNotification,
      notification.transactionSound,
      notification.stockAlert,
    ].where((value) => value).length;

    if (activeCount == 0) {
      return 'Semua notifikasi nonaktif';
    }

    if (activeCount == 3) {
      return 'Semua notifikasi aktif';
    }

    return '$activeCount preferensi aktif';
  },
);
