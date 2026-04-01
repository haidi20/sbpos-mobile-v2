import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';

abstract class SettingRepository {
  Future<Either<Failure, SettingConfigEntity>> getSettingConfig({
    bool? isOffline,
  });

  Future<Either<Failure, StoreInfoEntity>> updateStoreInfo(
    StoreInfoEntity storeInfo, {
    bool? isOffline,
  });

  Future<Either<Failure, PrinterSettingsEntity>> updatePrinterSettings(
    PrinterSettingsEntity printerSettings, {
    bool? isOffline,
  });

  Future<Either<Failure, List<PaymentMethodEntity>>> updatePaymentMethods(
    List<PaymentMethodEntity> paymentMethods, {
    bool? isOffline,
  });

  Future<Either<Failure, ProfileSettingsEntity>> updateProfileSettings(
    ProfileSettingsEntity profileSettings, {
    bool? isOffline,
  });

  Future<Either<Failure, NotificationPreferencesEntity>>
      updateNotificationPreferences(
    NotificationPreferencesEntity notificationPreferences, {
    bool? isOffline,
  });

  Future<Either<Failure, bool>> updateSecuritySettings(
    SecuritySettingsEntity securitySettings, {
    bool? isOffline,
  });
}
