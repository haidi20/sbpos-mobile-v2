import 'package:core/core.dart';
import 'package:core/data/datasources/core_local_data_source.dart';
import 'package:core/data/datasources/core_remote_data_source.dart';
import 'package:core/data/models/user_model.dart';
import 'package:core/data/responses/auth_response.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final CoreLocalDataSource local;
  final CoreRemoteDataSource remote;
  final NetworkInfo? networkInfo;

  static final Logger _logger = Logger('AuthRepositoryImpl');

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    this.networkInfo,
  });

  Future<Either<Failure, UserEntity>> _fallbackUserLocal({
    required String email,
    required String password,
  }) async {
    try {
      final response = await local.authenticationUser(
        email: email,
        password: password,
      );

      if (!response) {
        return const Left(ServerValidation('Email atau password salah'));
      }

      final storedUser = await local.getUser();
      if (storedUser == null) {
        _logger.warning('User lokal tidak ditemukan setelah autentikasi');
        return const Left(ServerFailure());
      }

      return Right(storedUser.toEntity());
    } catch (e, stackTrace) {
      _logger.severe('Error saat fallback ke lokal', e, stackTrace);
      return const Left(UnknownFailure());
    }
  }

  UserModel _mergeResponseUser({
    required AuthResponse response,
    required String password,
    UserModel? fallbackUser,
  }) {
    final remoteUser = response.user;
    return UserModel(
      id: remoteUser?.id ?? fallbackUser?.id,
      username: remoteUser?.username ?? fallbackUser?.username,
      email: remoteUser?.email ?? fallbackUser?.email,
      password: password,
      token: response.token ?? remoteUser?.token ?? fallbackUser?.token,
      refreshToken: response.refreshToken ??
          remoteUser?.refreshToken ??
          fallbackUser?.refreshToken,
      roleId: remoteUser?.roleId ?? fallbackUser?.roleId,
      warehouseId: remoteUser?.warehouseId ?? fallbackUser?.warehouseId,
      isActive: remoteUser?.isActive ?? fallbackUser?.isActive,
      lastLogin: DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> storeLogin({
    required String email,
    required String password,
  }) async {
    final resolvedNetworkInfo = networkInfo ?? NetworkInfoImpl(Connectivity());
    final isConnected = await resolvedNetworkInfo.isConnected;

    if (!isConnected) {
      return _fallbackUserLocal(
        email: email,
        password: password,
      );
    }

    try {
      final response = await remote.login(
        email: email,
        password: password,
      );

      if (response.user == null || response.token == null) {
        return const Left(ServerValidation('Email atau password tidak valid'));
      }

      final insertUserLocal = _mergeResponseUser(
        response: response,
        password: password,
      );

      await local.storeUser(user: insertUserLocal);
      return Right(insertUserLocal.toEntity());
    } on ServerValidation catch (e) {
      return Left(ServerValidation(e.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, stackTrace) {
      _logger.severe('Error tidak terduga saat login remote', e, stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshSession() async {
    try {
      final currentUser = await local.getUser();
      final refreshToken = currentUser?.refreshToken;

      if (currentUser == null || refreshToken == null || refreshToken.isEmpty) {
        return const Left(ServerValidation('Refresh token tidak tersedia'));
      }

      final response = await remote.refreshToken(refreshToken);
      final updatedUser = _mergeResponseUser(
        response: response,
        password: currentUser.password ?? '',
        fallbackUser: currentUser,
      );

      if ((updatedUser.token ?? '').isEmpty) {
        return const Left(ServerValidation('Token akses baru tidak tersedia'));
      }

      await local.storeUser(user: updatedUser);
      return Right(updatedUser.toEntity());
    } on ServerValidation catch (e) {
      return Left(ServerValidation(e.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, stackTrace) {
      _logger.severe('Error tidak terduga saat refresh session', e, stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      try {
        await remote.logout();
      } catch (_) {}

      await local.deleteUser();
      return const Right(true);
    } on Exception catch (e, stackTrace) {
      _logger.severe('Error during logout', e, stackTrace);
      return const Left(UnknownFailure());
    }
  }
}
