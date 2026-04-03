import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/usecases/update_security_settings.usecase.dart';
import 'package:setting/presentation/view_models/setting.state.dart';

class SettingSecurityViewModelActions {
  SettingSecurityViewModelActions({
    required UpdateSecuritySettings updateSecuritySettings,
    required SettingState Function() getState,
    required void Function(SettingState) setState,
  })  : _updateSecuritySettings = updateSecuritySettings,
        _getState = getState,
        _setState = setState;

  final UpdateSecuritySettings _updateSecuritySettings;
  final SettingState Function() _getState;
  final void Function(SettingState) _setState;

  void setSecurityOldPin(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        security: state.security.copyWith(
          oldPin: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  void setSecurityNewPin(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        security: state.security.copyWith(
          newPin: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  void setSecurityConfirmPin(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        security: state.security.copyWith(
          confirmPin: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  Future<bool> onUpdateSecurity() async {
    final state = _getState();
    final oldPin = state.security.oldPin.trim();
    final newPin = state.security.newPin.trim();
    final confirmPin = state.security.confirmPin.trim();

    if (oldPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      _setState(
        state.copyWith(
          security: state.security.copyWith(
            errorMessage: 'Semua field PIN wajib diisi',
            successMessage: '',
          ),
        ),
      );
      return false;
    }

    final pinRegex = RegExp(r'^\d{6}$');
    if (!pinRegex.hasMatch(oldPin) ||
        !pinRegex.hasMatch(newPin) ||
        !pinRegex.hasMatch(confirmPin)) {
      _setState(
        state.copyWith(
          security: state.security.copyWith(
            errorMessage: 'PIN harus terdiri dari 6 digit angka',
            successMessage: '',
          ),
        ),
      );
      return false;
    }

    if (newPin != confirmPin) {
      _setState(
        state.copyWith(
          security: state.security.copyWith(
            errorMessage: 'PIN baru dan konfirmasi PIN harus sama',
            successMessage: '',
          ),
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
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            security: nextState.security.copyWith(
              errorMessage: failure.message,
              successMessage: '',
            ),
          ),
        );
        return false;
      },
      (_) {
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            security: nextState.security.copyWith(
              oldPin: '',
              newPin: '',
              confirmPin: '',
              errorMessage: '',
              successMessage: 'Pengaturan keamanan berhasil diperbarui',
            ),
          ),
        );
        return true;
      },
    );
  }
}
