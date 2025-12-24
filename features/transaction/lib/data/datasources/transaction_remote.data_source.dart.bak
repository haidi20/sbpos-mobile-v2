import 'package:core/core.dart';
import 'package:transaction/data/responses/transaction.response.dart';

class TransactionRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;
  final _logger = Logger('TransactionRemoteDataSource');
  final bool isShowLog = false;

  TransactionRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<TransactionResponse> _callAndDecode(
      Future<dynamic> Function() request, String label) async {
    try {
      final response = await handleApiResponse(() async => await request());
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return TransactionResponse.fromJson(decoded);
    } catch (e, s) {
      if (isShowLog) _logger.severe('$label error: $e', e, s);
      rethrow;
    }
  }

  Future<TransactionResponse> fetchTransactions(
      {Map<String, dynamic>? params}) async {
    return await _callAndDecode(
      () =>
          _apiHelper.get(url: '$host/$api/transactions', params: params ?? {}),
      'fetchTransactions',
    );
  }

  /// Kirim transaksi ke API remote. Mengembalikan respons ter-decode.
  Future<TransactionResponse> postTransaction(
      Map<String, dynamic> payload) async {
    return await _callAndDecode(
      () => _apiHelper.post(url: '$host/$api/transactions', body: payload),
      'postTransaction',
    );
  }

  Future<TransactionResponse> fetchTransaction(int id) async {
    return await _callAndDecode(
        () => _apiHelper.get(url: '$host/$api/transactions/$id'),
        'fetchTransaction');
  }

  Future<TransactionResponse> updateTransaction(
      int id, Map<String, dynamic> payload) async {
    return await _callAndDecode(
        () => _apiHelper.put(url: '$host/$api/transactions/$id', body: payload),
        'updateTransaction');
  }

  Future<TransactionResponse> deleteTransaction(int id) async {
    return await _callAndDecode(
        () => _apiHelper.delete(url: '$host/$api/transactions/$id'),
        'deleteTransaction');
  }

  // _writeResponseToFile removed — tidak digunakan
}
