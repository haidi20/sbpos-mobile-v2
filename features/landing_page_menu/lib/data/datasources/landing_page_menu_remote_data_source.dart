// Remote data source for landing_page_menu
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:landing_page_menu/data/responses/landing_page_menu_response.dart';

class LandingPageMenuRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;
  final Logger _logger = Logger('LandingPageMenuRemoteDataSource');

  LandingPageMenuRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<LandingPageMenuResponse> fetchProducts() async {
    try {
      final response = await handleApiResponse(
        () async => _apiHelper.get(url: '$host/$api/products', params: {
          //
        }),
      );

      // await _writeResponseToFile(response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LandingPageMenuResponse.fromJson(decoded);
      } else if (response.statusCode == 401) {
        return LandingPageMenuResponse(
          message: 'Unauthorized',
          success: false,
          data: null,
        );
      } else {
        final errorMessage = decoded['message'] ?? 'Terjadi kesalahan server';
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // ignore: unused_element
  Future<void> _writeResponseToFile(dynamic response) async {
    if (!kDebugMode) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/response_api.json';
      final file = File(filePath);
      await file.writeAsString(response.body, flush: true);

      if (await file.exists()) {
        _logger.info("File response_api.json exists");
      } else {
        _logger.warning('❌ Failed to save file');
      }
    } catch (e, st) {
      _logger.severe('Error saving file: $e\n$st');
    }
  }
}
