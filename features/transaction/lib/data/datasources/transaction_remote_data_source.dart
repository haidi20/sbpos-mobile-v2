import 'package:core/core.dart';
import 'package:transaction/data/responses/transaction.response.dart';

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

  Future<TransactionResponse> fetchTransactions(
      {Map<String, dynamic>? params}) async {
    final response = await handleApiResponse(
      () async =>
          _apiHelper.get(url: '$host/$api/transactions', params: params ?? {}),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  /// Kirim transaksi ke API remote. Mengembalikan respons ter-decode.
  Future<TransactionResponse> postTransaction(
      Map<String, dynamic> payload) async {
    final response = await handleApiResponse(
      () async =>
          _apiHelper.post(url: '$host/$api/transactions', body: payload),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  Future<TransactionResponse> getTransaction(int id) async {
    final response = await handleApiResponse(
      () async => _apiHelper.get(url: '$host/$api/transactions/$id'),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  Future<TransactionResponse> updateTransaction(
      int id, Map<String, dynamic> payload) async {
    final response = await handleApiResponse(
      () async =>
          _apiHelper.put(url: '$host/$api/transactions/$id', body: payload),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  Future<TransactionResponse> deleteTransaction(int id) async {
    final response = await handleApiResponse(
      () async => _apiHelper.delete(url: '$host/$api/transactions/$id'),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionResponse.fromJson(decoded);
  }

  // _writeResponseToFile removed — tidak digunakan
}
