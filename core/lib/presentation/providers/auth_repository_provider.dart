// /lib/providers/repository_providers.dart
import 'package:core/core.dart';
import 'package:core/domain/repositories/auth_repository.dart';
import 'package:core/data/repositories/auth_repository_impl.dart';
import 'package:core/data/datasources/core_local_data_source.dart';
import 'package:core/data/datasources/core_remote_data_source.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final local = ref.read(authLocalDataSourceProvider);
  final remote = ref.read(authRemoteDataSourceProvider);

  return AuthRepositoryImpl(
    remote: remote,
    local: local,
  );
});

final authRemoteDataSourceProvider = Provider<CoreRemoteDataSource>(
  (ref) => CoreRemoteDataSource(),
);

final authLocalDataSourceProvider = Provider<CoreLocalDataSource>(
  (ref) => CoreLocalDataSource(),
);
