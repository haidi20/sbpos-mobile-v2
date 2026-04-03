import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/usecases/update_store_info.usecase.dart';
import 'package:setting/presentation/view_models/setting.state.dart';

class SettingStoreViewModelActions {
  SettingStoreViewModelActions({
    required UpdateStoreInfo updateStoreInfo,
    required SettingState Function() getState,
    required void Function(SettingState) setState,
    required StoreInfoState Function(StoreInfoEntity) mapStoreEntityToState,
  })  : _updateStoreInfo = updateStoreInfo,
        _getState = getState,
        _setState = setState,
        _mapStoreEntityToState = mapStoreEntityToState;

  final UpdateStoreInfo _updateStoreInfo;
  final SettingState Function() _getState;
  final void Function(SettingState) _setState;
  final StoreInfoState Function(StoreInfoEntity) _mapStoreEntityToState;

  void setStoreName(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        store: state.store.copyWith(
          storeName: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  void setStoreBranch(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        store: state.store.copyWith(
          branch: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  void setStoreAddress(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        store: state.store.copyWith(
          address: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  void setStorePhone(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        store: state.store.copyWith(
          phone: value,
          errorMessage: '',
          successMessage: '',
        ),
      ),
    );
  }

  Future<bool> onSaveStoreInfo() async {
    final state = _getState();
    final storeName = state.store.storeName.trim();
    final branch = state.store.branch.trim();
    final address = state.store.address.trim();
    final phone = state.store.phone.trim();

    if (storeName.isEmpty ||
        branch.isEmpty ||
        address.isEmpty ||
        phone.isEmpty) {
      _setState(
        state.copyWith(
          store: state.store.copyWith(
            errorMessage: 'Semua field informasi toko wajib diisi',
            successMessage: '',
          ),
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
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            store: nextState.store.copyWith(
              errorMessage: failure.message,
              successMessage: '',
            ),
          ),
        );
        return false;
      },
      (store) {
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            store: _mapStoreEntityToState(store).copyWith(
              errorMessage: '',
              successMessage: 'Informasi toko berhasil diperbarui',
            ),
          ),
        );
        return true;
      },
    );
  }
}
