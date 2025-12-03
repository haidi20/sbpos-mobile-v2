import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse/data/responses/warehouse_response.dart';

class WarehouseRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  WarehouseRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<WarehouseResponse> fetchWarehouses() async {
    // print("Fetching warehouses from $host/$api/warehouses");

    final response = await handleApiResponse(
      () async => _apiHelper.get(url: '$host/$api/warehouses', params: {
        //
      }),
    );

    // await _writeResponseToFile(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    // debug info (disabled in production)
    // debugPrint("decoded : $decoded");
    return WarehouseResponse.fromJson(decoded);
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
        debugPrint('ada file response_api.json');
      } else {
        debugPrint('❌ Gagal menyimpan file');
      }
    } catch (e, st) {
      debugPrint('Error menyimpan file: $e\n$st');
    }
  }
}
