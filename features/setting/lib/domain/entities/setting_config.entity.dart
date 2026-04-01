import 'package:core/core.dart';

@immutable
class StoreInfoEntity {
  final String storeName;
  final String branch;
  final String address;
  final String phone;

  const StoreInfoEntity({
    required this.storeName,
    required this.branch,
    required this.address,
    required this.phone,
  });

  StoreInfoEntity copyWith({
    String? storeName,
    String? branch,
    String? address,
    String? phone,
  }) {
    return StoreInfoEntity(
      storeName: storeName ?? this.storeName,
      branch: branch ?? this.branch,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }
}

@immutable
class PrinterDeviceEntity {
  final String name;
  final String subtitle;
  final bool isConnected;

  const PrinterDeviceEntity({
    required this.name,
    required this.subtitle,
    required this.isConnected,
  });

  PrinterDeviceEntity copyWith({
    String? name,
    String? subtitle,
    bool? isConnected,
  }) {
    return PrinterDeviceEntity(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

@immutable
class PrinterSettingsEntity {
  final bool autoPrint;
  final bool printLogo;
  final String paperWidth;
  final List<PrinterDeviceEntity> devices;

  const PrinterSettingsEntity({
    required this.autoPrint,
    required this.printLogo,
    required this.paperWidth,
    required this.devices,
  });

  PrinterSettingsEntity copyWith({
    bool? autoPrint,
    bool? printLogo,
    String? paperWidth,
    List<PrinterDeviceEntity>? devices,
  }) {
    return PrinterSettingsEntity(
      autoPrint: autoPrint ?? this.autoPrint,
      printLogo: printLogo ?? this.printLogo,
      paperWidth: paperWidth ?? this.paperWidth,
      devices: devices ?? this.devices,
    );
  }
}

@immutable
class PaymentMethodEntity {
  final int id;
  final String name;
  final bool isActive;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    required this.isActive,
  });

  PaymentMethodEntity copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return PaymentMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}

@immutable
class ProfileSettingsEntity {
  final String name;
  final String employeeId;
  final String email;
  final String phone;

  const ProfileSettingsEntity({
    required this.name,
    required this.employeeId,
    required this.email,
    required this.phone,
  });

  ProfileSettingsEntity copyWith({
    String? name,
    String? employeeId,
    String? email,
    String? phone,
  }) {
    return ProfileSettingsEntity(
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

@immutable
class NotificationPreferencesEntity {
  final bool pushNotification;
  final bool transactionSound;
  final bool stockAlert;

  const NotificationPreferencesEntity({
    required this.pushNotification,
    required this.transactionSound,
    required this.stockAlert,
  });

  NotificationPreferencesEntity copyWith({
    bool? pushNotification,
    bool? transactionSound,
    bool? stockAlert,
  }) {
    return NotificationPreferencesEntity(
      pushNotification: pushNotification ?? this.pushNotification,
      transactionSound: transactionSound ?? this.transactionSound,
      stockAlert: stockAlert ?? this.stockAlert,
    );
  }
}

@immutable
class SecuritySettingsEntity {
  final String oldPin;
  final String newPin;
  final String confirmPin;

  const SecuritySettingsEntity({
    required this.oldPin,
    required this.newPin,
    required this.confirmPin,
  });

  SecuritySettingsEntity copyWith({
    String? oldPin,
    String? newPin,
    String? confirmPin,
  }) {
    return SecuritySettingsEntity(
      oldPin: oldPin ?? this.oldPin,
      newPin: newPin ?? this.newPin,
      confirmPin: confirmPin ?? this.confirmPin,
    );
  }
}

@immutable
class SettingConfigEntity {
  final StoreInfoEntity store;
  final PrinterSettingsEntity printer;
  final List<PaymentMethodEntity> paymentMethods;
  final ProfileSettingsEntity profile;
  final NotificationPreferencesEntity notifications;
  final SecuritySettingsEntity security;
  final String versionLabel;

  const SettingConfigEntity({
    required this.store,
    required this.printer,
    required this.paymentMethods,
    required this.profile,
    required this.notifications,
    required this.security,
    required this.versionLabel,
  });

  SettingConfigEntity copyWith({
    StoreInfoEntity? store,
    PrinterSettingsEntity? printer,
    List<PaymentMethodEntity>? paymentMethods,
    ProfileSettingsEntity? profile,
    NotificationPreferencesEntity? notifications,
    SecuritySettingsEntity? security,
    String? versionLabel,
  }) {
    return SettingConfigEntity(
      store: store ?? this.store,
      printer: printer ?? this.printer,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      profile: profile ?? this.profile,
      notifications: notifications ?? this.notifications,
      security: security ?? this.security,
      versionLabel: versionLabel ?? this.versionLabel,
    );
  }
}
