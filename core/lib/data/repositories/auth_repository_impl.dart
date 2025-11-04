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

  Future<Either<Failure, UserEntity>> _fallbackUserLocal() async {
    try {
      final UserModel? localUser = await local.getUser();
      if (localUser != null) {
        if (localUser.token == null) {
          _logger.warning(
            'Token lokal null saat fallback ke lokal, kemungkinan user belum login sebelumnya',
          );
          return const Left(LocalValidation("Token lokal tidak tersedia"));
        }

        return Right(localUser.toEntity());
      } else {
        _logger.warning(
            'Fallback ke lokal gagal: tidak ada user di penyimpanan lokal');
        // atau NetworkFailure jika lebih sesuai konteks

        return const Left(
          CacheFailure(),
        );
      }
    } catch (e, stackTrace) {
      _logger.severe('Error saat fallback ke lokal', e, stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> storeLogin({
    required String username,
    required String password,
  }) async {
    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final AuthResponse response = await remote.login(
          username: username,
          password: password,
        );

        if (response.user != null) {
          await local.storeUser(user: response.user!);

          if (response.user?.token == null) {
            _logger.warning(
              'Token dari server null, tidak dapat menyimpan token lokal',
            );

            return const Left(ServerValidation('Token tidak tersedia'));
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
      return await _fallbackUserLocal();
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // 2. Hapus data lokal (user, token, dll)
      await local.deleteToken();

      return const Right(true);
    } on Exception catch (e) {
      _logger.severe('Error during logout', e);
      return const Left(UnknownFailure());
    }
  }
}
