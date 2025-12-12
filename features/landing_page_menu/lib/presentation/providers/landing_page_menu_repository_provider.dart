// Repository provider for landing_page_menu
import 'package:core/core.dart';
import 'package:landing_page_menu/data/datasources/landing_page_menu_remote.datasource.dart';
import 'package:landing_page_menu/domain/repositories/landing_page_menu_repository.dart';
import 'package:landing_page_menu/data/repositories/landing_page_menu_repository_impl.dart';

final landingPageMenuRemoteDataSourceProvider =
    Provider<LandingPageMenuRemoteDataSource>(
  (ref) => LandingPageMenuRemoteDataSource(),
);

final landingPageMenuRepositoryProvider =
    Provider<LandingPageMenuRepository>((ref) {
  final remote = ref.read(landingPageMenuRemoteDataSourceProvider);

  return LandingPageMenuRepositoryImpl(
    remote: remote,
  );
});
