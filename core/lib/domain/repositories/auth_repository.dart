import 'package:core/core.dart';
import 'package:core/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> storeLogin({
    required String email,
    required String password,
  });

  Future<Either<Failure, bool>> logout();
}
