part of 'package:setting/presentation/view_models/setting.vm.dart';

mixin _SettingStoreViewModelMixin on _SettingViewModelScope {
  void setStoreName(String value) {
    state = state.copyWith(
      store: state.store.copyWith(
        storeName: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  void setStoreBranch(String value) {
    state = state.copyWith(
      store: state.store.copyWith(
        branch: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  void setStoreAddress(String value) {
    state = state.copyWith(
      store: state.store.copyWith(
        address: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  void setStorePhone(String value) {
    state = state.copyWith(
      store: state.store.copyWith(
        phone: value,
        errorMessage: '',
        successMessage: '',
      ),
    );
  }

  Future<bool> onSaveStoreInfo() async {
    final storeName = state.store.storeName.trim();
    final branch = state.store.branch.trim();
    final address = state.store.address.trim();
    final phone = state.store.phone.trim();

    if (storeName.isEmpty ||
        branch.isEmpty ||
        address.isEmpty ||
        phone.isEmpty) {
      state = state.copyWith(
        store: state.store.copyWith(
          errorMessage: 'Semua field informasi toko wajib diisi',
          successMessage: '',
        ),
      );
      return false;
    }

    final result = await _updateStoreInfo(
      StoreInfoEntity(
        storeName: storeName,
        branch: branch,
        address: address,
        phone: phone,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          store: state.store.copyWith(
            errorMessage: failure.message,
            successMessage: '',
          ),
        );
        return false;
      },
      (store) {
        state = state.copyWith(
          store: _mapStoreEntityToState(store).copyWith(
            errorMessage: '',
            successMessage: 'Informasi toko berhasil diperbarui',
          ),
        );
        return true;
      },
    );
  }
}
