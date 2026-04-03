import 'package:core/core.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/usecases/logout.dart';
import 'package:core/domain/usecases/refresh_session.dart';
import 'package:core/domain/usecases/store_login.dart';

class AuthState {
  final bool isLoading;
  final UserEntity? authUser;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.authUser,
    this.error,
  });

  bool get isAuthenticated => authUser != null;

  AuthState copyWith({
    bool? isLoading,
    UserEntity? authUser,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      authUser: clearUser ? null : (authUser ?? this.authUser),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final StoreLogin _storeLogin;
  final Logout _logout;
  final RefreshSession _refreshSession;

  AuthViewModel(
    this._storeLogin,
    this._logout,
    this._refreshSession,
  ) : super(const AuthState());

  Future<bool> storeLogin({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _storeLogin.call(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (authUser) {
        state = state.copyWith(
          isLoading: false,
          authUser: authUser,
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<bool> refreshSession() async {
    final result = await _refreshSession.call();
    return result.fold(
      (failure) {
        state = state.copyWith(
          error: failure.message,
        );
        return false;
      },
      (authUser) {
        state = state.copyWith(
          authUser: authUser,
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: false, clearError: true);

    final result = await _logout.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
          clearUser: true,
        );
      },
    );
  }
}
