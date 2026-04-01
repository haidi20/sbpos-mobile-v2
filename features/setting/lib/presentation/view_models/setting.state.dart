import 'package:core/core.dart';
import 'package:setting/presentation/view_models/setting/help.state.dart';
import 'package:setting/presentation/view_models/setting/notification_preferences.state.dart';
import 'package:setting/presentation/view_models/setting/payment_settings.state.dart';
import 'package:setting/presentation/view_models/setting/printer_settings.state.dart';
import 'package:setting/presentation/view_models/setting/profile_form.state.dart';
import 'package:setting/presentation/view_models/setting/security_form.state.dart';
import 'package:setting/presentation/view_models/setting/setting_profile_card.state.dart';
import 'package:setting/presentation/view_models/setting/store_info.state.dart';

export 'package:setting/presentation/view_models/setting/help.state.dart';
export 'package:setting/presentation/view_models/setting/notification_preferences.state.dart';
export 'package:setting/presentation/view_models/setting/payment_settings.state.dart';
export 'package:setting/presentation/view_models/setting/printer_settings.state.dart';
export 'package:setting/presentation/view_models/setting/profile_form.state.dart';
export 'package:setting/presentation/view_models/setting/security_form.state.dart';
export 'package:setting/presentation/view_models/setting/setting_profile_card.state.dart';
export 'package:setting/presentation/view_models/setting/store_info.state.dart';

@immutable
class SettingState {
  final SettingProfileCardState profileCard;
  final StoreInfoState store;
  final PrinterSettingsState printer;
  final PaymentSettingsState payment;
  final ProfileFormState profile;
  final NotificationPreferencesState notification;
  final SecurityFormState security;
  final HelpState help;
  final String versionLabel;

  const SettingState({
    required this.profileCard,
    required this.store,
    required this.printer,
    required this.payment,
    required this.profile,
    required this.notification,
    required this.security,
    required this.help,
    required this.versionLabel,
  });

  const SettingState.initial()
      : profileCard = const SettingProfileCardState.initial(),
        store = const StoreInfoState.initial(),
        printer = const PrinterSettingsState.initial(),
        payment = const PaymentSettingsState.initial(),
        profile = const ProfileFormState.initial(),
        notification = const NotificationPreferencesState.initial(),
        security = const SecurityFormState.initial(),
        help = const HelpState.initial(),
        versionLabel = 'SBPOS App v2';

  SettingState copyWith({
    SettingProfileCardState? profileCard,
    StoreInfoState? store,
    PrinterSettingsState? printer,
    PaymentSettingsState? payment,
    ProfileFormState? profile,
    NotificationPreferencesState? notification,
    SecurityFormState? security,
    HelpState? help,
    String? versionLabel,
  }) {
    return SettingState(
      profileCard: profileCard ?? this.profileCard,
      store: store ?? this.store,
      printer: printer ?? this.printer,
      payment: payment ?? this.payment,
      profile: profile ?? this.profile,
      notification: notification ?? this.notification,
      security: security ?? this.security,
      help: help ?? this.help,
      versionLabel: versionLabel ?? this.versionLabel,
    );
  }
}
