import 'package:core/core.dart';
import '../responses/outlet.response.dart';

class OutletRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  OutletRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<OutletResponse> fetchOutlets() async {
    final response = await handleApiResponse(
      () async => _apiHelper.get(url: '$host/$api/outlets', params: {
        //
      }),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return OutletResponse.fromJson(decoded);
  }

  // Debug helper removed to avoid referencing path_provider/file IO
}
