import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Data source untuk mengambil data transaksi dari API remote.
/// Struktur dan perilaku mengikuti pola pada `warehouse_remote_data_source.dart`.
class TransactionRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  TransactionRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<dynamic> fetchTransactions({Map<String, dynamic>? params}) async {
    final response = await handleApiResponse(
      () async =>
          _apiHelper.get(url: '$host/$api/transactions', params: params ?? {}),
    );

    final decoded = jsonDecode(response.body);
    return decoded;
  }

  Future<void> _writeResponseToFile(dynamic response) async {
    if (!kDebugMode) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/response_transactions.json';
      final file = File(filePath);
      await file.writeAsString(response.body, flush: true);
    } catch (e, st) {
      print('Error menyimpan file transactions: $e\n$st');
    }
  }
}
