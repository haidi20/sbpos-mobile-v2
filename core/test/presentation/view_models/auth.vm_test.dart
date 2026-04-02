import 'package:core/core.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/repositories/auth_repository.dart';
import 'package:core/domain/usecases/logout.dart';
import 'package:core/domain/usecases/refresh_session.dart';
import 'package:core/domain/usecases/store_login.dart';
import 'package:core/presentation/view_models/auth.vm.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  Either<Failure, UserEntity> loginResult = const Right(
    UserEntity(
      id: 1,
      username: 'Kasir',
      email: 'kasir@demo.com',
      token: 'token',
      refreshToken: 'refresh',
    ),
  );
  Either<Failure, UserEntity> refreshResult = const Right(
    UserEntity(
      id: 1,
      username: 'Kasir',
      email: 'kasir@demo.com',
      token: 'token-baru',
      refreshToken: 'refresh-baru',
    ),
  );
  Either<Failure, bool> logoutResult = const Right(true);

  @override
  Future<Either<Failure, bool>> logout() async => logoutResult;

  @override
  Future<Either<Failure, UserEntity>> refreshSession() async => refreshResult;

  @override
  Future<Either<Failure, UserEntity>> storeLogin({
    required String email,
    required String password,
  }) async =>
      loginResult;
}

void main() {
  late _FakeAuthRepository repository;
  late AuthViewModel viewModel;

  setUp(() {
    repository = _FakeAuthRepository();
    viewModel = AuthViewModel(
      StoreLogin(repository),
      Logout(repository),
      RefreshSession(repository),
    );
  });

  test('storeLogin menyimpan authUser saat sukses', () async {
    final success = await viewModel.storeLogin(
      email: 'kasir@demo.com',
      password: 'kasirdemo',
    );

    expect(success, isTrue);
    expect(viewModel.state.isAuthenticated, isTrue);
    expect(viewModel.state.authUser?.token, 'token');
    expect(viewModel.state.isLoading, isFalse);
  });

  test('storeLogin menyimpan error saat gagal', () async {
    repository.loginResult = const Left(ServerValidation('Login gagal'));

    final success = await viewModel.storeLogin(
      email: 'kasir@demo.com',
      password: 'kasirdemo',
    );

    expect(success, isFalse);
    expect(viewModel.state.isAuthenticated, isFalse);
    expect(viewModel.state.error, 'Login gagal');
  });

  test('refreshSession memperbarui token user aktif', () async {
    await viewModel.storeLogin(
      email: 'kasir@demo.com',
      password: 'kasirdemo',
    );

    final success = await viewModel.refreshSession();

    expect(success, isTrue);
    expect(viewModel.state.authUser?.token, 'token-baru');
  });

  test('logout menghapus authUser dari state', () async {
    await viewModel.storeLogin(
      email: 'kasir@demo.com',
      password: 'kasirdemo',
    );

    await viewModel.logout();

    expect(viewModel.state.authUser, isNull);
    expect(viewModel.state.isAuthenticated, isFalse);
  });
}
