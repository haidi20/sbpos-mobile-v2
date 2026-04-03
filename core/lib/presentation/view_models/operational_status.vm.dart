import 'package:core/core.dart';
import 'package:core/domain/usecases/check_service_status.dart';
import 'package:core/domain/usecases/check_subscription_status.dart';

class OperationalStatusViewModel extends StateNotifier<OperationalStatusState> {
  OperationalStatusViewModel(
    this._checkServiceStatus,
    this._checkSubscriptionStatus,
  ) : super(const OperationalStatusState());

  final CheckServiceStatus _checkServiceStatus;
  final CheckSubscriptionStatus _checkSubscriptionStatus;

  Future<void> refreshStatus() async {
    if (state.isChecking) {
      return;
    }

    state = state.copyWith(
      isChecking: true,
      errorMessage: '',
    );

    final serviceResult = await _checkServiceStatus();
    final subscriptionResult = await _checkSubscriptionStatus();

    var nextState = state.copyWith(
      isChecking: false,
      isServiceAvailable: true,
      isSubscriptionActive: true,
      blockTitle: '',
      blockMessage: '',
    );

    serviceResult.fold(
      (failure) {
        nextState = nextState.copyWith(
          errorMessage: failure.message,
        );
      },
      (serviceStatus) {
        nextState = nextState.copyWith(
          isServiceAvailable: serviceStatus.isAllowed,
          blockTitle: serviceStatus.isAllowed ? nextState.blockTitle : 'Layanan POS Tidak Aktif',
          blockMessage:
              serviceStatus.isAllowed ? nextState.blockMessage : serviceStatus.message,
        );
      },
    );

    subscriptionResult.fold(
      (failure) {
        nextState = nextState.copyWith(
          errorMessage: nextState.errorMessage.isEmpty
              ? failure.message
              : nextState.errorMessage,
        );
      },
      (subscriptionStatus) {
        nextState = nextState.copyWith(
          isSubscriptionActive: subscriptionStatus.isAllowed,
          blockTitle: subscriptionStatus.isAllowed
              ? nextState.blockTitle
              : 'Langganan SB POS Tidak Aktif',
          blockMessage: subscriptionStatus.isAllowed
              ? nextState.blockMessage
              : subscriptionStatus.message,
        );
      },
    );

    state = nextState;
  }
}
