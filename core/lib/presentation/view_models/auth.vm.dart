import 'package:core/core.dart';
import 'package:core/domain/usecases/logout.dart';
import 'package:core/domain/entities/user_entity.dart';
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
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      authUser: authUser ?? this.authUser,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final StoreLogin _storeLogin;
  final Logout _logout;

  AuthViewModel(
    this._storeLogin,
    this._logout,
  ) : super(const AuthState()) {
    // Future.microtask(checkAuth);
  }

  Future<void> storeLogin({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final Either<Failure, UserEntity> result = await _storeLogin.call(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (authUser) {
        state = state.copyWith(
          authUser: authUser,
        );

        Future.delayed(
          const Duration(seconds: 1),
          () {
            state = state.copyWith(
              isLoading: false,
              clearError: true,
            );
          },
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: false, error: null);

    final Either<Failure, bool> result = await _logout.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (success) {
        state = const AuthState();
      },
    );

    // Tambahkan logika logout jika diperlukan
  }
}
