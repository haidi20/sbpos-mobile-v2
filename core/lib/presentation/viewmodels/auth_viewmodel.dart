import 'package:core/core.dart';
import 'package:core/domain/usecases/logout.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/usecases/store_login.dart';

class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
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
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final Either<Failure, UserEntity> result = await _storeLogin.call(
      username: username,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
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
