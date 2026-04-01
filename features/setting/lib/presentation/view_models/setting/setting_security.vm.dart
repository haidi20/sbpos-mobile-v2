part of 'package:setting/presentation/view_models/setting.vm.dart';

mixin _SettingSecurityViewModelMixin on _SettingViewModelScope {
  void setSecurityOldPin(String value) {
    state = state.copyWith(
      security: state.security.copyWith(
        oldPin: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  void setSecurityNewPin(String value) {
    state = state.copyWith(
      security: state.security.copyWith(
        newPin: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  void setSecurityConfirmPin(String value) {
    state = state.copyWith(
      security: state.security.copyWith(
        confirmPin: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  Future<bool> onUpdateSecurity() async {
    final oldPin = state.security.oldPin.trim();
    final newPin = state.security.newPin.trim();
    final confirmPin = state.security.confirmPin.trim();

    if (oldPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      state = state.copyWith(
        security: state.security.copyWith(
          errorMessage: 'Semua field PIN wajib diisi',
          successMessage: '',
        ),
      );
      return false;
    }

    final pinRegex = RegExp(r'^\d{6}$');
    if (!pinRegex.hasMatch(oldPin) ||
        !pinRegex.hasMatch(newPin) ||
        !pinRegex.hasMatch(confirmPin)) {
      state = state.copyWith(
        security: state.security.copyWith(
          errorMessage: 'PIN harus terdiri dari 6 digit angka',
          successMessage: '',
        ),
      );
      return false;
    }

    if (newPin != confirmPin) {
      state = state.copyWith(
        security: state.security.copyWith(
          errorMessage: 'PIN baru dan konfirmasi PIN harus sama',
          successMessage: '',
        ),
      );
      return false;
    }

    final result = await _updateSecuritySettings(
      SecuritySettingsEntity(
        oldPin: oldPin,
        newPin: newPin,
        confirmPin: confirmPin,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          security: state.security.copyWith(
            errorMessage: failure.message,
            successMessage: '',
          ),
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          security: state.security.copyWith(
            oldPin: '',
            newPin: '',
            confirmPin: '',
            errorMessage: '',
            successMessage: 'Pengaturan keamanan berhasil diperbarui',
          ),
        );
        return true;
      },
    );
  }
}
