import 'package:core/core.dart';

@immutable
class NotificationPreferencesState {
  final bool pushNotification;
  final bool transactionSound;
  final bool stockAlert;

  const NotificationPreferencesState({
    required this.pushNotification,
    required this.transactionSound,
    required this.stockAlert,
  });

  const NotificationPreferencesState.initial()
      : pushNotification = true,
        transactionSound = true,
        stockAlert = true;

  NotificationPreferencesState copyWith({
    bool? pushNotification,
    bool? transactionSound,
    bool? stockAlert,
  }) {
    return NotificationPreferencesState(
      pushNotification: pushNotification ?? this.pushNotification,
      transactionSound: transactionSound ?? this.transactionSound,
      stockAlert: stockAlert ?? this.stockAlert,
    );
  }
}
