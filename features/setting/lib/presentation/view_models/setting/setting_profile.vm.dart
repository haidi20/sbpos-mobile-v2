import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/usecases/update_profile_settings.usecase.dart';
import 'package:setting/presentation/view_models/setting.state.dart';

class SettingProfileViewModelActions {
  SettingProfileViewModelActions({
    required UpdateProfileSettings updateProfileSettings,
    required SettingState Function() getState,
    required void Function(SettingState) setState,
    required ProfileFormState Function(ProfileSettingsEntity)
        mapProfileEntityToState,
  })  : _updateProfileSettings = updateProfileSettings,
        _getState = getState,
        _setState = setState,
        _mapProfileEntityToState = mapProfileEntityToState;

  final UpdateProfileSettings _updateProfileSettings;
  final SettingState Function() _getState;
  final void Function(SettingState) _setState;
  final ProfileFormState Function(ProfileSettingsEntity)
      _mapProfileEntityToState;

  void setProfileName(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        profile: state.profile.copyWith(
          name: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  void setProfileEmployeeId(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        profile: state.profile.copyWith(
          employeeId: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  void setProfileEmail(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        profile: state.profile.copyWith(
          email: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  void setProfilePhone(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        profile: state.profile.copyWith(
          phone: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  Future<bool> onSaveProfile() async {
    final state = _getState();
    final name = state.profile.name.trim();
    final email = state.profile.email.trim();
    final phone = state.profile.phone.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _setState(
        state.copyWith(
          profile: state.profile.copyWith(
            errorMessage: 'Nama, email, dan nomor handphone wajib diisi',
            successMessage: '',
          ),
        ),
      );
      return false;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _setState(
        state.copyWith(
          profile: state.profile.copyWith(
            errorMessage: 'Format email tidak valid',
            successMessage: '',
          ),
        ),
      );
      return false;
    }

    final result = await _updateProfileSettings(
      ProfileSettingsEntity(
        name: name,
        employeeId: state.profile.employeeId.trim(),
        email: email,
        phone: phone,
      ),
    );

    return result.fold(
      (failure) {
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            profile: nextState.profile.copyWith(
              errorMessage: failure.message,
              successMessage: '',
            ),
          ),
        );
        return false;
      },
      (profile) {
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            profile: _mapProfileEntityToState(profile).copyWith(
              errorMessage: '',
              successMessage: 'Profil berhasil diperbarui',
            ),
            profileCard: nextState.profileCard.copyWith(name: profile.name),
          ),
        );
        return true;
      },
    );
  }
}
