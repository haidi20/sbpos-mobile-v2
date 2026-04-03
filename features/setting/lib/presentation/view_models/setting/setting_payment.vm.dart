import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/usecases/update_payment_methods.usecase.dart';
import 'package:setting/presentation/view_models/setting.state.dart';

class SettingPaymentViewModelActions {
  SettingPaymentViewModelActions({
    required UpdatePaymentMethods updatePaymentMethods,
    required SettingState Function() getState,
    required void Function(SettingState) setState,
  })  : _updatePaymentMethods = updatePaymentMethods,
        _getState = getState,
        _setState = setState;

  final UpdatePaymentMethods _updatePaymentMethods;
  final SettingState Function() _getState;
  final void Function(SettingState) _setState;

  void setPaymentMethodActive(int id, bool isActive) {
    final state = _getState();
    final updatedMethods = state.payment.methods.map((method) {
      if (method.id != id) {
        return method;
      }

      return method.copyWith(isActive: isActive);
    }).toList();

    _setState(
      state.copyWith(
        payment: state.payment.copyWith(methods: updatedMethods),
      ),
    );
    unawaited(onSavePaymentMethods());
  }

  Future<bool> onSavePaymentMethods() async {
    final state = _getState();
    final result = await _updatePaymentMethods(
      state.payment.methods
          .map(
            (method) => PaymentMethodEntity(
              id: method.id,
              name: method.name,
              isActive: method.isActive,
            ),
          )
          .toList(),
    );

    return result.fold(
      (_) => false,
      (methods) {
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            payment: nextState.payment.copyWith(
              methods: methods
                  .map(
                    (method) => PaymentMethodState(
                      id: method.id,
                      name: method.name,
                      isActive: method.isActive,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
        return true;
      },
    );
  }
}
