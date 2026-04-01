part of 'package:setting/presentation/view_models/setting.vm.dart';

mixin _SettingPaymentViewModelMixin on _SettingViewModelScope {
  void setPaymentMethodActive(int id, bool isActive) {
    final updatedMethods = state.payment.methods.map((method) {
      if (method.id != id) {
        return method;
      }

      return method.copyWith(isActive: isActive);
    }).toList();

    state = state.copyWith(
      payment: state.payment.copyWith(methods: updatedMethods),
    );
    unawaited(onSavePaymentMethods());
  }

  Future<bool> onSavePaymentMethods() async {
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
        state = state.copyWith(
          payment: state.payment.copyWith(
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
        );
        return true;
      },
    );
  }
}
