import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/usecases/update_notification_preferences.usecase.dart';
import 'package:setting/presentation/view_models/setting.state.dart';

class SettingNotificationViewModelActions {
  SettingNotificationViewModelActions({
    required UpdateNotificationPreferences updateNotificationPreferences,
    required SettingState Function() getState,
    required void Function(SettingState) setState,
    required NotificationPreferencesState Function(NotificationPreferencesEntity)
        mapNotificationEntityToState,
  })  : _updateNotificationPreferences = updateNotificationPreferences,
        _getState = getState,
        _setState = setState,
        _mapNotificationEntityToState = mapNotificationEntityToState;

  final UpdateNotificationPreferences _updateNotificationPreferences;
  final SettingState Function() _getState;
  final void Function(SettingState) _setState;
  final NotificationPreferencesState Function(NotificationPreferencesEntity)
      _mapNotificationEntityToState;

  void setPushNotification(bool value) {
    final state = _getState();
    _setState(
      state.copyWith(
        notification: state.notification.copyWith(pushNotification: value),
      ),
    );
    unawaited(onSaveNotificationPreferences());
  }

  void setTransactionSound(bool value) {
    final state = _getState();
    _setState(
      state.copyWith(
        notification: state.notification.copyWith(transactionSound: value),
      ),
    );
    unawaited(onSaveNotificationPreferences());
  }

  void setStockAlert(bool value) {
    final state = _getState();
    _setState(
      state.copyWith(
        notification: state.notification.copyWith(stockAlert: value),
      ),
    );
    unawaited(onSaveNotificationPreferences());
  }

  Future<bool> onSaveNotificationPreferences() async {
    final state = _getState();
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
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            notification: _mapNotificationEntityToState(notification),
          ),
        );
        return true;
      },
    );
  }
}
