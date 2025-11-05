import 'package:core/core.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/repositories/auth_repository.dart';

class StoreLogin {
  final AuthRepository repository;

  StoreLogin(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.storeLogin(
      email: email,
      password: password,
    );
  }
}
