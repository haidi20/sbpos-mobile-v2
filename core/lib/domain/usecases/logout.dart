import 'package:core/core.dart';
import 'package:core/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.logout();
  }
}
