// Implementation of landing_page_menu repository
import 'package:landing_page_menu/data/datasources/landing_page_menu_remote.datasource.dart';
import 'package:landing_page_menu/domain/repositories/landing_page_menu_repository.dart';

class LandingPageMenuRepositoryImpl implements LandingPageMenuRepository {
  final LandingPageMenuRemoteDataSource remote;

  // static final Logger _logger = Logger('LandingPageMenuRepositoryImpl');

  LandingPageMenuRepositoryImpl({
    required this.remote,
  });
}
