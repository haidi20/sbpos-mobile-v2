import 'package:core/core.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/repositories/auth_repository.dart';
import 'package:core/domain/usecases/logout.dart';
import 'package:core/domain/usecases/refresh_session.dart';
import 'package:core/domain/usecases/store_login.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.onStoreLogin,
    this.onRefreshSession,
    this.onLogout,
  });

  final Future<Either<Failure, UserEntity>> Function({
    required String email,
    required String password,
  })? onStoreLogin;
  final Future<Either<Failure, UserEntity>> Function()? onRefreshSession;
  final Future<Either<Failure, bool>> Function()? onLogout;

  @override
  Future<Either<Failure, bool>> logout() {
    final handler = onLogout;
    if (handler == null) {
      return Future.value(const Right(true));
    }
    return handler();
  }

  @override
  Future<Either<Failure, UserEntity>> refreshSession() {
    final handler = onRefreshSession;
    if (handler == null) {
      return Future.value(const Right(UserEntity(
        id: 1,
        username: 'kasir',
        email: 'kasir@sbpos.test',
        token: 'token-baru',
        refreshToken: 'refresh-baru',
      )));
    }
    return handler();
  }

  @override
  Future<Either<Failure, UserEntity>> storeLogin({
    required String email,
    required String password,
  }) {
    final handler = onStoreLogin;
    if (handler == null) {
      return Future.value(const Right(UserEntity(
        id: 1,
        username: 'kasir',
        email: 'kasir@sbpos.test',
        token: 'token',
      )));
    }
    return handler(email: email, password: password);
  }
}

Future<void> expectLeftFailure<T>(
  Future<Either<Failure, T>> Function() action,
  Matcher matcher,
) async {
  final result = await action();
  result.fold(
    (failure) => expect(failure, matcher),
    (_) => fail('Expected Left result'),
  );
}

void main() {
  group('StoreLogin', () {
    test('returns user from repository on success', () async {
      const expected = UserEntity(
        id: 7,
        username: 'admin',
        email: 'admin@sbpos.test',
        token: 'abc123',
      );
      final repository = FakeAuthRepository(
        onStoreLogin: ({required email, required password}) async {
          expect(email, 'admin@sbpos.test');
          expect(password, 'secret');
          return const Right(expected);
        },
      );

      final result = await StoreLogin(repository)(
        email: 'admin@sbpos.test',
        password: 'secret',
      );

      result.fold(
        (_) => fail('Expected Right result'),
        (user) => expect(user, expected),
      );
    });

    test('passes repository left result through unchanged', () async {
      final repository = FakeAuthRepository(
        onStoreLogin: ({required email, required password}) async =>
            const Left(ServerFailure()),
      );

      await expectLeftFailure(
        () => StoreLogin(repository)(
          email: 'admin@sbpos.test',
          password: 'secret',
        ),
        isA<ServerFailure>(),
      );
    });

    test('maps thrown Failure into Left', () async {
      const failure = NetworkFailure();
      final repository = FakeAuthRepository(
        onStoreLogin: ({required email, required password}) =>
            Future.error(failure),
      );

      await expectLeftFailure(
        () => StoreLogin(repository)(
          email: 'admin@sbpos.test',
          password: 'secret',
        ),
        same(failure),
      );
    });

    test('maps unexpected exception into UnknownFailure', () async {
      final repository = FakeAuthRepository(
        onStoreLogin: ({required email, required password}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => StoreLogin(repository)(
          email: 'admin@sbpos.test',
          password: 'secret',
        ),
        isA<UnknownFailure>(),
      );
    });
  });

  group('Logout', () {
    test('returns repository result on success', () async {
      final repository = FakeAuthRepository(
        onLogout: () async => const Right(true),
      );

      final result = await Logout(repository)();

      result.fold(
        (_) => fail('Expected Right result'),
        (isLoggedOut) => expect(isLoggedOut, isTrue),
      );
    });

    test('passes repository left result through unchanged', () async {
      final repository = FakeAuthRepository(
        onLogout: () async => const Left(ServerFailure()),
      );

      await expectLeftFailure(
        () => Logout(repository)(),
        isA<ServerFailure>(),
      );
    });

    test('maps thrown Failure into Left', () async {
      const failure = LocalValidation('token kosong');
      final repository = FakeAuthRepository(
        onLogout: () => Future.error(failure),
      );

      await expectLeftFailure(
        () => Logout(repository)(),
        same(failure),
      );
    });

    test('maps unexpected exception into UnknownFailure', () async {
      final repository = FakeAuthRepository(
        onLogout: () => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => Logout(repository)(),
        isA<UnknownFailure>(),
      );
    });
  });

  group('RefreshSession', () {
    test('returns refreshed user from repository on success', () async {
      const expected = UserEntity(
        id: 5,
        username: 'kasir',
        email: 'kasir@sbpos.test',
        token: 'token-baru',
        refreshToken: 'refresh-baru',
      );
      final repository = FakeAuthRepository(
        onRefreshSession: () async => const Right(expected),
      );

      final result = await RefreshSession(repository)();

      result.fold(
        (_) => fail('Expected Right result'),
        (user) => expect(user, expected),
      );
    });

    test('passes repository failure through unchanged', () async {
      final repository = FakeAuthRepository(
        onRefreshSession: () async =>
            const Left(ServerValidation('refresh token tidak tersedia')),
      );

      await expectLeftFailure(
        () => RefreshSession(repository)(),
        isA<ServerValidation>(),
      );
    });

    test('maps thrown unexpected exception into UnknownFailure', () async {
      final repository = FakeAuthRepository(
        onRefreshSession: () => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => RefreshSession(repository)(),
        isA<UnknownFailure>(),
      );
    });
  });
}
