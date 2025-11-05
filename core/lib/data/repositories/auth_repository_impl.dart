import 'package:core/core.dart';
import 'package:core/data/models/user_model.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/repositories/auth_repository.dart';
import 'package:core/data/datasources/core_local_data_source.dart';
import 'package:core/data/datasources/core_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final CoreLocalDataSource local;
  final CoreRemoteDataSource remote;

  static final Logger _logger = Logger('AuthRepositoryImpl');

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
  });

  Future<Either<Failure, UserEntity>> _fallbackUserLocal({
    required String email,
    required String password,
  }) async {
    try {
      final bool response = await local.authenticationUser(
        email: email,
        password: password,
      );

      if (response) {
        final UserModel? storedUser = await local.getUser();

        if (storedUser != null) {
          return Right(storedUser.toEntity());
        } else {
          _logger.warning('User lokal tidak ditemukan setelah autentikasi');
          return const Left(ServerFailure());
        }
      } else {
        _logger.info('Autentikasi user lokal gagal');
        return const Left(ServerValidation('Email atau password salah'));
      }
    } catch (e, stackTrace) {
      _logger.severe('Error saat fallback ke lokal', e, stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> storeLogin({
    required String email,
    required String password,
  }) async {
    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final AuthResponse response = await remote.login(
          email: email,
          password: password,
        );

        if (response.user != null) {
          UserModel insertUserLocal = UserModel().copyWith(
            username: response.user!.username,
            email: response.user!.email,
            token: response.user!.token,
            password: password,
          );

          await local.storeUser(user: insertUserLocal);

          if (response.user?.token == null) {
            _logger.warning(
              'Token dari server null, tidak dapat menyimpan token lokal',
            );

            return const Left(
                ServerValidation('Maaf, ada kesalahan pada autentikasi'));
          }

          return Right(response.user!.toEntity());
        } else {
          _logger.warning('Server mengembalikan sukses tetapi user null');
          return const Left(ServerFailure());
        }
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e, stackTrace) {
        _logger.severe('Error tidak terduga saat login remote', e, stackTrace);
        return const Left(UnknownFailure());
      }
    } else {
      // Selalu fallback ke lokal saat offline
      return await _fallbackUserLocal(
        email: email,
        password: password,
      );
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // 2. Hapus data lokal (user, token, dll)
      // await local.deleteToken();

      return const Right(true);
    } on Exception catch (e) {
      _logger.severe('Error during logout', e);
      return const Left(UnknownFailure());
    }
  }
}
