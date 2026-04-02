import 'package:core/core.dart';
import 'package:core/data/datasources/core_local_data_source.dart';
import 'package:core/data/datasources/core_remote_data_source.dart';
import 'package:core/data/models/user_model.dart';
import 'package:core/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo(this._isConnected);

  final bool _isConnected;

  @override
  Future<bool> get isConnected async => _isConnected;
}

class _FakeCoreLocalDataSource extends CoreLocalDataSource {
  UserModel? storedUser;
  bool authenticationResult = false;
  int storeUserCallCount = 0;
  int deleteUserCallCount = 0;

  @override
  Future<bool> authenticationUser({
    required String email,
    required String password,
  }) async {
    return authenticationResult;
  }

  @override
  Future<UserModel?> getUser() async => storedUser;

  @override
  Future<String> storeUser({
    required UserModel user,
  }) async {
    storedUser = user;
    storeUserCallCount += 1;
    return 'ok';
  }

  @override
  Future<void> deleteUser() async {
    storedUser = null;
    deleteUserCallCount += 1;
  }
}

class _FakeCoreRemoteDataSource extends CoreRemoteDataSource {
  _FakeCoreRemoteDataSource() : super();

  AuthResponse loginResponse = AuthResponse(
    user: UserModel(
      id: 1,
      username: 'Kasir Satu',
      email: 'kasir@demo.com',
      token: 'access-1',
      refreshToken: 'refresh-1',
      roleId: 2,
      warehouseId: 8,
      isActive: true,
    ),
    token: 'access-1',
    refreshToken: 'refresh-1',
  );
  AuthResponse refreshResponse = AuthResponse(
    user: UserModel(
      id: 1,
      username: 'Kasir Satu',
      email: 'kasir@demo.com',
      token: 'access-2',
      refreshToken: 'refresh-2',
      roleId: 2,
      warehouseId: 8,
      isActive: true,
    ),
    token: 'access-2',
    refreshToken: 'refresh-2',
  );

  @override
  Future<AuthResponse> login({
    String? email,
    String? password,
  }) async {
    return loginResponse;
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    return refreshResponse;
  }

  @override
  Future<AuthResponse?> logout({
    String? deviceToken,
  }) async {
    return AuthResponse(
      user: null,
      token: null,
      refreshToken: null,
    );
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    test('storeLogin menyimpan session lengkap dari remote ke lokal', () async {
      final local = _FakeCoreLocalDataSource();
      final remote = _FakeCoreRemoteDataSource();
      final repository = AuthRepositoryImpl(
        remote: remote,
        local: local,
        networkInfo: _FakeNetworkInfo(true),
      );

      final result = await repository.storeLogin(
        email: 'kasir@demo.com',
        password: 'kasirdemo',
      );

      expect(local.storeUserCallCount, 1);
      expect(local.storedUser?.token, 'access-1');
      expect(local.storedUser?.refreshToken, 'refresh-1');
      expect(local.storedUser?.roleId, 2);
      expect(local.storedUser?.warehouseId, 8);
      expect(local.storedUser?.password, 'kasirdemo');
      result.fold(
        (_) => fail('Expected login success'),
        (user) {
          expect(user.token, 'access-1');
          expect(user.refreshToken, 'refresh-1');
          expect(user.roleId, 2);
        },
      );
    });

    test('refreshSession memperbarui access token lokal', () async {
      final local = _FakeCoreLocalDataSource()
        ..storedUser = UserModel(
          id: 1,
          username: 'Kasir Satu',
          email: 'kasir@demo.com',
          password: 'kasirdemo',
          token: 'access-1',
          refreshToken: 'refresh-1',
          roleId: 2,
          warehouseId: 8,
          isActive: true,
        );
      final remote = _FakeCoreRemoteDataSource();
      final repository = AuthRepositoryImpl(
        remote: remote,
        local: local,
        networkInfo: _FakeNetworkInfo(true),
      );

      final result = await repository.refreshSession();

      expect(local.storeUserCallCount, 1);
      expect(local.storedUser?.token, 'access-2');
      expect(local.storedUser?.refreshToken, 'refresh-2');
      result.fold(
        (_) => fail('Expected refresh success'),
        (user) => expect(user.token, 'access-2'),
      );
    });

    test('logout membersihkan session lokal', () async {
      final local = _FakeCoreLocalDataSource()
        ..storedUser = UserModel(
          id: 1,
          username: 'Kasir Satu',
          email: 'kasir@demo.com',
          token: 'access-1',
          refreshToken: 'refresh-1',
        );
      final remote = _FakeCoreRemoteDataSource();
      final repository = AuthRepositoryImpl(
        remote: remote,
        local: local,
        networkInfo: _FakeNetworkInfo(true),
      );

      final result = await repository.logout();

      expect(local.deleteUserCallCount, 1);
      expect(local.storedUser, isNull);
      result.fold(
        (_) => fail('Expected logout success'),
        (success) => expect(success, isTrue),
      );
    });
  });
}
