import 'package:core/core.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/repositories/auth_repository.dart';

class RefreshSession {
  final AuthRepository repository;

  RefreshSession(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    try {
      return await repository.refreshSession();
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
