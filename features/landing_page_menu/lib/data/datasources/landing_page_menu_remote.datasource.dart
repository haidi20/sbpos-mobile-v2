import 'package:core/core.dart';
import 'package:landing_page_menu/data/responses/landing_page_menu_response.dart';

class LandingPageMenuRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  LandingPageMenuRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<LandingPageMenuResponse> fetchLandingPages(
      {Map<String, dynamic>? params}) async {
    final response = await handleApiResponse(
      () async =>
          _apiHelper.get(url: '$host/$api/landing_pages', params: params ?? {}),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return LandingPageMenuResponse.fromJson(decoded);
  }

  // Debug helper removed to avoid referencing path_provider/file IO
}
