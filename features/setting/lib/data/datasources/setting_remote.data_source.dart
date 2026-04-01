import 'package:setting/data/models/setting_config.model.dart';

abstract class SettingRemoteDataSource {
  /// Request:
  /// {}
  ///
  /// Expected response:
  /// {
  ///   "data": {
  ///     "store": {...},
  ///     "printer": {...},
  ///     "payment_methods": [...],
  ///     "profile": {...},
  ///     "notifications": {...},
  ///     "version_label": "SBPOS App v2"
  ///   }
  /// }
  Future<SettingConfigModel> getSettingConfig();

  /// Request:
  /// {
  ///   "store_name": "...",
  ///   "branch": "...",
  ///   "address": "...",
  ///   "phone": "..."
  /// }
  ///
  /// Expected response:
  /// {
  ///   "data": {
  ///     "store_name": "...",
  ///     "branch": "...",
  ///     "address": "...",
  ///     "phone": "..."
  ///   },
  ///   "message": "Informasi toko berhasil diperbarui"
  /// }
  Future<StoreInfoModel> updateStoreInfo(StoreInfoModel storeInfo);

  /// Request:
  /// {
  ///   "auto_print": true,
  ///   "print_logo": true,
  ///   "paper_width": "80mm",
  ///   "devices": [...]
  /// }
  ///
  /// Expected response:
  /// {
  ///   "data": {
  ///     "auto_print": true,
  ///     "print_logo": true,
  ///     "paper_width": "80mm",
  ///     "devices": [...]
  ///   },
  ///   "message": "Pengaturan printer berhasil diperbarui"
  /// }
  Future<PrinterSettingsModel> updatePrinterSettings(
    PrinterSettingsModel printerSettings,
  );

  /// Request:
  /// {
  ///   "payment_methods": [
  ///     {"id": 1, "name": "Tunai (Cash)", "is_active": true}
  ///   ]
  /// }
  ///
  /// Expected response:
  /// {
  ///   "data": [
  ///     {"id": 1, "name": "Tunai (Cash)", "is_active": true}
  ///   ],
  ///   "message": "Metode pembayaran berhasil diperbarui"
  /// }
  Future<List<PaymentMethodModel>> updatePaymentMethods(
    List<PaymentMethodModel> paymentMethods,
  );

  /// Request:
  /// {
  ///   "name": "...",
  ///   "employee_id": "...",
  ///   "email": "...",
  ///   "phone": "..."
  /// }
  ///
  /// Expected response:
  /// {
  ///   "data": {
  ///     "name": "...",
  ///     "employee_id": "...",
  ///     "email": "...",
  ///     "phone": "..."
  ///   },
  ///   "message": "Profil berhasil diperbarui"
  /// }
  Future<ProfileSettingsModel> updateProfileSettings(
    ProfileSettingsModel profileSettings,
  );

  /// Request:
  /// {
  ///   "push_notification": true,
  ///   "transaction_sound": true,
  ///   "stock_alert": true
  /// }
  ///
  /// Expected response:
  /// {
  ///   "data": {
  ///     "push_notification": true,
  ///     "transaction_sound": true,
  ///     "stock_alert": true
  ///   },
  ///   "message": "Preferensi notifikasi berhasil diperbarui"
  /// }
  Future<NotificationPreferencesModel> updateNotificationPreferences(
    NotificationPreferencesModel notificationPreferences,
  );

  /// Request:
  /// {
  ///   "old_pin": "123456",
  ///   "new_pin": "654321",
  ///   "confirm_pin": "654321"
  /// }
  ///
  /// Expected response:
  /// {
  ///   "data": true,
  ///   "message": "Pengaturan keamanan berhasil diperbarui"
  /// }
  Future<bool> updateSecuritySettings(SecuritySettingsModel securitySettings);
}
