part of 'package:setting/presentation/view_models/setting.vm.dart';

mixin _SettingProfileViewModelMixin on _SettingViewModelScope {
  void setProfileName(String value) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        name: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  void setProfileEmployeeId(String value) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        employeeId: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  void setProfileEmail(String value) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        email: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  void setProfilePhone(String value) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        phone: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  Future<bool> onSaveProfile() async {
    final name = state.profile.name.trim();
    final email = state.profile.email.trim();
    final phone = state.profile.phone.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      state = state.copyWith(
        profile: state.profile.copyWith(
          errorMessage: 'Nama, email, dan nomor handphone wajib diisi',
          successMessage: '',
        ),
      );
      return false;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      state = state.copyWith(
        profile: state.profile.copyWith(
          errorMessage: 'Format email tidak valid',
          successMessage: '',
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
        state = state.copyWith(
          profile: state.profile.copyWith(
            errorMessage: failure.message,
            successMessage: '',
          ),
        );
        return false;
      },
      (profile) {
        state = state.copyWith(
          profile: _mapProfileEntityToState(profile).copyWith(
            errorMessage: '',
            successMessage: 'Profil berhasil diperbarui',
          ),
          profileCard: state.profileCard.copyWith(name: profile.name),
        );
        return true;
      },
    );
  }
}
