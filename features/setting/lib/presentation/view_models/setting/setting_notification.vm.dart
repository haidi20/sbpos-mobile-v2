part of 'package:setting/presentation/view_models/setting.vm.dart';

mixin _SettingNotificationViewModelMixin on _SettingViewModelScope {
  void setPushNotification(bool value) {
    state = state.copyWith(
      notification: state.notification.copyWith(pushNotification: value),
    );
    unawaited(onSaveNotificationPreferences());
  }

  void setTransactionSound(bool value) {
    state = state.copyWith(
      notification: state.notification.copyWith(transactionSound: value),
    );
    unawaited(onSaveNotificationPreferences());
  }

  void setStockAlert(bool value) {
    state = state.copyWith(
      notification: state.notification.copyWith(stockAlert: value),
    );
    unawaited(onSaveNotificationPreferences());
  }

  Future<bool> onSaveNotificationPreferences() async {
    final result = await _updateNotificationPreferences(
      NotificationPreferencesEntity(
        pushNotification: state.notification.pushNotification,
        transactionSound: state.notification.transactionSound,
        stockAlert: state.notification.stockAlert,
      ),
    );

    return result.fold(
      (_) => false,
      (notification) {
        state = state.copyWith(
          notification: _mapNotificationEntityToState(notification),
        );
        return true;
      },
    );
  }
}
