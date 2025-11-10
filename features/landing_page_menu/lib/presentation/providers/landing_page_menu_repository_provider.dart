// Repository provider for landing_page_menu
import 'package:core/core.dart';
import 'package:landing_page_menu/domain/repositories/landing_page_menu_repository.dart';
import 'package:landing_page_menu/data/repositories/landing_page_menu_repository_impl.dart';
import 'package:landing_page_menu/data/datasources/landing_page_menu_local_data_source.dart';
import 'package:landing_page_menu/data/datasources/landing_page_menu_remote_data_source.dart';

final landingPageMenuRemoteDataSourceProvider =
    Provider<LandingPageMenuRemoteDataSource>(
  (ref) => LandingPageMenuRemoteDataSource(),
);

final landingPageMenuLocalDataSourceProvider =
    Provider<LandingPageMenuLocalDataSource>(
  (ref) => LandingPageMenuLocalDataSource(),
);

final landingPageMenuRepositoryProvider =
    Provider<LandingPageMenuRepository>((ref) {
  final remote = ref.read(landingPageMenuRemoteDataSourceProvider);
  final local = ref.read(landingPageMenuLocalDataSourceProvider);

  return LandingPageMenuRepositoryImpl(
    remote: remote,
    local: local,
  );
});
