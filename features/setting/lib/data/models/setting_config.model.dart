import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';

@immutable
class StoreInfoModel {
  final String storeName;
  final String branch;
  final String address;
  final String phone;

  const StoreInfoModel({
    required this.storeName,
    required this.branch,
    required this.address,
    required this.phone,
  });

  factory StoreInfoModel.fromJson(Map<String, dynamic> json) {
    return StoreInfoModel(
      storeName: json['store_name'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  factory StoreInfoModel.fromEntity(StoreInfoEntity entity) {
    return StoreInfoModel(
      storeName: entity.storeName,
      branch: entity.branch,
      address: entity.address,
      phone: entity.phone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'branch': branch,
      'address': address,
      'phone': phone,
    };
  }

  StoreInfoEntity toEntity() {
    return StoreInfoEntity(
      storeName: storeName,
      branch: branch,
      address: address,
      phone: phone,
    );
  }

  StoreInfoModel copyWith({
    String? storeName,
    String? branch,
    String? address,
    String? phone,
  }) {
    return StoreInfoModel(
      storeName: storeName ?? this.storeName,
      branch: branch ?? this.branch,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }
}

@immutable
class PrinterDeviceModel {
  final String name;
  final String subtitle;
  final bool isConnected;

  const PrinterDeviceModel({
    required this.name,
    required this.subtitle,
    required this.isConnected,
  });

  factory PrinterDeviceModel.fromJson(Map<String, dynamic> json) {
    return PrinterDeviceModel(
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      isConnected: json['is_connected'] as bool? ?? false,
    );
  }

  factory PrinterDeviceModel.fromEntity(PrinterDeviceEntity entity) {
    return PrinterDeviceModel(
      name: entity.name,
      subtitle: entity.subtitle,
      isConnected: entity.isConnected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subtitle': subtitle,
      'is_connected': isConnected,
    };
  }

  PrinterDeviceEntity toEntity() {
    return PrinterDeviceEntity(
      name: name,
      subtitle: subtitle,
      isConnected: isConnected,
    );
  }

  PrinterDeviceModel copyWith({
    String? name,
    String? subtitle,
    bool? isConnected,
  }) {
    return PrinterDeviceModel(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

@immutable
class PrinterSettingsModel {
  final bool autoPrint;
  final bool printLogo;
  final String paperWidth;
  final List<PrinterDeviceModel> devices;

  const PrinterSettingsModel({
    required this.autoPrint,
    required this.printLogo,
    required this.paperWidth,
    required this.devices,
  });

  factory PrinterSettingsModel.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] as List<dynamic>? ?? const [];
    return PrinterSettingsModel(
      autoPrint: json['auto_print'] as bool? ?? false,
      printLogo: json['print_logo'] as bool? ?? false,
      paperWidth: json['paper_width'] as String? ?? '80mm',
      devices: devicesJson
          .whereType<Map<String, dynamic>>()
          .map(PrinterDeviceModel.fromJson)
          .toList(),
    );
  }

  factory PrinterSettingsModel.fromEntity(PrinterSettingsEntity entity) {
    return PrinterSettingsModel(
      autoPrint: entity.autoPrint,
      printLogo: entity.printLogo,
      paperWidth: entity.paperWidth,
      devices: entity.devices.map(PrinterDeviceModel.fromEntity).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_print': autoPrint,
      'print_logo': printLogo,
      'paper_width': paperWidth,
      'devices': devices.map((device) => device.toJson()).toList(),
    };
  }

  PrinterSettingsEntity toEntity() {
    return PrinterSettingsEntity(
      autoPrint: autoPrint,
      printLogo: printLogo,
      paperWidth: paperWidth,
      devices: devices.map((device) => device.toEntity()).toList(),
    );
  }

  PrinterSettingsModel copyWith({
    bool? autoPrint,
    bool? printLogo,
    String? paperWidth,
    List<PrinterDeviceModel>? devices,
  }) {
    return PrinterSettingsModel(
      autoPrint: autoPrint ?? this.autoPrint,
      printLogo: printLogo ?? this.printLogo,
      paperWidth: paperWidth ?? this.paperWidth,
      devices: devices ?? this.devices,
    );
  }
}

@immutable
class PaymentMethodModel {
  final int id;
  final String name;
  final bool isActive;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  factory PaymentMethodModel.fromEntity(PaymentMethodEntity entity) {
    return PaymentMethodModel(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
    };
  }

  PaymentMethodEntity toEntity() {
    return PaymentMethodEntity(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  PaymentMethodModel copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}

@immutable
class ProfileSettingsModel {
  final String name;
  final String employeeId;
  final String email;
  final String phone;

  const ProfileSettingsModel({
    required this.name,
    required this.employeeId,
    required this.email,
    required this.phone,
  });

  factory ProfileSettingsModel.fromJson(Map<String, dynamic> json) {
    return ProfileSettingsModel(
      name: json['name'] as String? ?? '',
      employeeId: json['employee_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  factory ProfileSettingsModel.fromEntity(ProfileSettingsEntity entity) {
    return ProfileSettingsModel(
      name: entity.name,
      employeeId: entity.employeeId,
      email: entity.email,
      phone: entity.phone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'employee_id': employeeId,
      'email': email,
      'phone': phone,
    };
  }

  ProfileSettingsEntity toEntity() {
    return ProfileSettingsEntity(
      name: name,
      employeeId: employeeId,
      email: email,
      phone: phone,
    );
  }

  ProfileSettingsModel copyWith({
    String? name,
    String? employeeId,
    String? email,
    String? phone,
  }) {
    return ProfileSettingsModel(
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

@immutable
class NotificationPreferencesModel {
  final bool pushNotification;
  final bool transactionSound;
  final bool stockAlert;

  const NotificationPreferencesModel({
    required this.pushNotification,
    required this.transactionSound,
    required this.stockAlert,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      pushNotification: json['push_notification'] as bool? ?? false,
      transactionSound: json['transaction_sound'] as bool? ?? false,
      stockAlert: json['stock_alert'] as bool? ?? false,
    );
  }

  factory NotificationPreferencesModel.fromEntity(
    NotificationPreferencesEntity entity,
  ) {
    return NotificationPreferencesModel(
      pushNotification: entity.pushNotification,
      transactionSound: entity.transactionSound,
      stockAlert: entity.stockAlert,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_notification': pushNotification,
      'transaction_sound': transactionSound,
      'stock_alert': stockAlert,
    };
  }

  NotificationPreferencesEntity toEntity() {
    return NotificationPreferencesEntity(
      pushNotification: pushNotification,
      transactionSound: transactionSound,
      stockAlert: stockAlert,
    );
  }

  NotificationPreferencesModel copyWith({
    bool? pushNotification,
    bool? transactionSound,
    bool? stockAlert,
  }) {
    return NotificationPreferencesModel(
      pushNotification: pushNotification ?? this.pushNotification,
      transactionSound: transactionSound ?? this.transactionSound,
      stockAlert: stockAlert ?? this.stockAlert,
    );
  }
}

@immutable
class SecuritySettingsModel {
  final String oldPin;
  final String newPin;
  final String confirmPin;

  const SecuritySettingsModel({
    required this.oldPin,
    required this.newPin,
    required this.confirmPin,
  });

  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) {
    return SecuritySettingsModel(
      oldPin: json['old_pin'] as String? ?? '',
      newPin: json['new_pin'] as String? ?? '',
      confirmPin: json['confirm_pin'] as String? ?? '',
    );
  }

  factory SecuritySettingsModel.fromEntity(SecuritySettingsEntity entity) {
    return SecuritySettingsModel(
      oldPin: entity.oldPin,
      newPin: entity.newPin,
      confirmPin: entity.confirmPin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'old_pin': oldPin,
      'new_pin': newPin,
      'confirm_pin': confirmPin,
    };
  }

  SecuritySettingsEntity toEntity() {
    return SecuritySettingsEntity(
      oldPin: oldPin,
      newPin: newPin,
      confirmPin: confirmPin,
    );
  }

  SecuritySettingsModel copyWith({
    String? oldPin,
    String? newPin,
    String? confirmPin,
  }) {
    return SecuritySettingsModel(
      oldPin: oldPin ?? this.oldPin,
      newPin: newPin ?? this.newPin,
      confirmPin: confirmPin ?? this.confirmPin,
    );
  }
}

@immutable
class SettingConfigModel {
  final StoreInfoModel store;
  final PrinterSettingsModel printer;
  final List<PaymentMethodModel> paymentMethods;
  final ProfileSettingsModel profile;
  final NotificationPreferencesModel notifications;
  final SecuritySettingsModel security;
  final String versionLabel;

  const SettingConfigModel({
    required this.store,
    required this.printer,
    required this.paymentMethods,
    required this.profile,
    required this.notifications,
    required this.security,
    required this.versionLabel,
  });

  factory SettingConfigModel.fromJson(Map<String, dynamic> json) {
    final paymentMethodsJson =
        json['payment_methods'] as List<dynamic>? ?? const [];

    return SettingConfigModel(
      store: StoreInfoModel.fromJson(
        json['store'] as Map<String, dynamic>? ?? const {},
      ),
      printer: PrinterSettingsModel.fromJson(
        json['printer'] as Map<String, dynamic>? ?? const {},
      ),
      paymentMethods: paymentMethodsJson
          .whereType<Map<String, dynamic>>()
          .map(PaymentMethodModel.fromJson)
          .toList(),
      profile: ProfileSettingsModel.fromJson(
        json['profile'] as Map<String, dynamic>? ?? const {},
      ),
      notifications: NotificationPreferencesModel.fromJson(
        json['notifications'] as Map<String, dynamic>? ?? const {},
      ),
      security: SecuritySettingsModel.fromJson(
        json['security'] as Map<String, dynamic>? ?? const {},
      ),
      versionLabel: json['version_label'] as String? ?? '',
    );
  }

  factory SettingConfigModel.fromEntity(SettingConfigEntity entity) {
    return SettingConfigModel(
      store: StoreInfoModel.fromEntity(entity.store),
      printer: PrinterSettingsModel.fromEntity(entity.printer),
      paymentMethods: entity.paymentMethods
          .map(PaymentMethodModel.fromEntity)
          .toList(),
      profile: ProfileSettingsModel.fromEntity(entity.profile),
      notifications: NotificationPreferencesModel.fromEntity(
        entity.notifications,
      ),
      security: SecuritySettingsModel.fromEntity(entity.security),
      versionLabel: entity.versionLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store': store.toJson(),
      'printer': printer.toJson(),
      'payment_methods': paymentMethods.map((item) => item.toJson()).toList(),
      'profile': profile.toJson(),
      'notifications': notifications.toJson(),
      'security': security.toJson(),
      'version_label': versionLabel,
    };
  }

  factory SettingConfigModel.fromDbLocal(Map<String, dynamic> map) {
    final paymentMethodsJson = _decodeJsonList(map['payment_methods_json']);
    final printerDevicesJson = _decodeJsonList(map['printer_devices_json']);

    return SettingConfigModel(
      store: StoreInfoModel(
        storeName: map['store_name'] as String? ?? '',
        branch: map['branch'] as String? ?? '',
        address: map['address'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
      ),
      printer: PrinterSettingsModel(
        autoPrint: _toBool(map['printer_auto_print']),
        printLogo: _toBool(map['printer_print_logo']),
        paperWidth: map['printer_paper_width'] as String? ?? '80mm',
        devices: printerDevicesJson
            .whereType<Map<String, dynamic>>()
            .map(PrinterDeviceModel.fromJson)
            .toList(),
      ),
      paymentMethods: paymentMethodsJson
          .whereType<Map<String, dynamic>>()
          .map(PaymentMethodModel.fromJson)
          .toList(),
      profile: ProfileSettingsModel(
        name: map['profile_name'] as String? ?? '',
        employeeId: map['profile_employee_id'] as String? ?? '',
        email: map['profile_email'] as String? ?? '',
        phone: map['profile_phone'] as String? ?? '',
      ),
      notifications: NotificationPreferencesModel(
        pushNotification: _toBool(map['notification_push']),
        transactionSound: _toBool(map['notification_transaction_sound']),
        stockAlert: _toBool(map['notification_stock_alert']),
      ),
      security: SecuritySettingsModel(
        oldPin: map['security_old_pin'] as String? ?? '',
        newPin: map['security_new_pin'] as String? ?? '',
        confirmPin: map['security_confirm_pin'] as String? ?? '',
      ),
      versionLabel: map['version_label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toDbLocal({int id = 1}) {
    return {
      'id': id,
      'store_name': store.storeName,
      'branch': store.branch,
      'address': store.address,
      'phone': store.phone,
      'printer_auto_print': printer.autoPrint ? 1 : 0,
      'printer_print_logo': printer.printLogo ? 1 : 0,
      'printer_paper_width': printer.paperWidth,
      'printer_devices_json': jsonEncode(
        printer.devices.map((item) => item.toJson()).toList(),
      ),
      'payment_methods_json': jsonEncode(
        paymentMethods.map((item) => item.toJson()).toList(),
      ),
      'profile_name': profile.name,
      'profile_employee_id': profile.employeeId,
      'profile_email': profile.email,
      'profile_phone': profile.phone,
      'notification_push': notifications.pushNotification ? 1 : 0,
      'notification_transaction_sound': notifications.transactionSound ? 1 : 0,
      'notification_stock_alert': notifications.stockAlert ? 1 : 0,
      'security_old_pin': security.oldPin,
      'security_new_pin': security.newPin,
      'security_confirm_pin': security.confirmPin,
      'version_label': versionLabel,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  SettingConfigEntity toEntity() {
    return SettingConfigEntity(
      store: store.toEntity(),
      printer: printer.toEntity(),
      paymentMethods: paymentMethods.map((item) => item.toEntity()).toList(),
      profile: profile.toEntity(),
      notifications: notifications.toEntity(),
      security: security.toEntity(),
      versionLabel: versionLabel,
    );
  }

  SettingConfigModel copyWith({
    StoreInfoModel? store,
    PrinterSettingsModel? printer,
    List<PaymentMethodModel>? paymentMethods,
    ProfileSettingsModel? profile,
    NotificationPreferencesModel? notifications,
    SecuritySettingsModel? security,
    String? versionLabel,
  }) {
    return SettingConfigModel(
      store: store ?? this.store,
      printer: printer ?? this.printer,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      profile: profile ?? this.profile,
      notifications: notifications ?? this.notifications,
      security: security ?? this.security,
      versionLabel: versionLabel ?? this.versionLabel,
    );
  }

  static List<dynamic> _decodeJsonList(Object? raw) {
    if (raw is List<dynamic>) {
      return raw;
    }
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return decoded;
      }
    }
    return const [];
  }

  static bool _toBool(Object? value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }
}
