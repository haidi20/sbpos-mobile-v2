import 'package:core/core.dart';
import 'package:core/domain/usecases/logout.dart';
import 'package:core/domain/usecases/refresh_session.dart';
import 'package:core/domain/usecases/store_login.dart';
import 'package:core/presentation/view_models/auth.vm.dart';
import 'package:core/presentation/providers/auth_repository_provider.dart';

final storeLoginProvider = Provider<StoreLogin>((ref) {
  final repo = ref.read(authRepositoryProvider);

  return StoreLogin(repo);
});

final logoutProvider = Provider<Logout>((ref) {
  final repo = ref.read(authRepositoryProvider);

  return Logout(repo);
});

final refreshSessionProvider = Provider<RefreshSession>((ref) {
  final repo = ref.read(authRepositoryProvider);

  return RefreshSession(repo);
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final storeLogin = ref.watch(storeLoginProvider);
  final logout = ref.watch(logoutProvider);
  final refreshSession = ref.watch(refreshSessionProvider);
  return AuthViewModel(storeLogin, logout, refreshSession);
});
