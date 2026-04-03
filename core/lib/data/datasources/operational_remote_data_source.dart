import 'package:core/core.dart';
import 'package:core/data/responses/operational_check.response.dart';
import 'package:http/http.dart' as http;

typedef OperationalGetRequest = Future<http.Response> Function({
  required String url,
  Map<String, dynamic>? params,
});

class OperationalRemoteDataSource with BaseErrorHelper {
  OperationalRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
    OperationalGetRequest? getRequest,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper(),
        _getRequest = getRequest;

  final String host;
  final String api;
  final ApiHelper _apiHelper;
  final OperationalGetRequest? _getRequest;

  Future<http.Response> _get({
    required String url,
    Map<String, dynamic>? params,
  }) {
    final request = _getRequest;
    if (request != null) {
      return request(url: url, params: params);
    }
    return _apiHelper.get(url: url, params: params);
  }

  Future<OperationalCheckResponse> checkServiceStatus() async {
    final response = await handleApiResponse(
      () async => _get(
        url: '$host/$api/service/check',
      ),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OperationalCheckResponse.fromJson(json);
  }

  Future<OperationalCheckResponse> checkSubscriptionStatus() async {
    final response = await handleApiResponse(
      () async => _get(
        url: '$host/$api/subscription/status',
      ),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OperationalCheckResponse.fromJson(json);
  }
}
