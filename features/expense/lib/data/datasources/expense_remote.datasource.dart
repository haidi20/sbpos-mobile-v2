import 'package:core/core.dart';
import 'package:expense/data/responses/expense.response.dart';

class ExpenseRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  ExpenseRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<ExpenseResponse> fetchExpenses({Map<String, dynamic>? params}) async {
    try {
      final response = await handleApiResponse(() async =>
          _apiHelper.get(url: '$host/$api/expense', params: params ?? {}));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ExpenseResponse.fromJson(decoded);
    } catch (e) {
      rethrow;
    }
  }

  Future<ExpenseResponse> postExpense(Map<String, dynamic> payload) async {
    try {
      final response = await handleApiResponse(() async =>
          _apiHelper.post(url: '$host/$api/expense/add', body: payload));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ExpenseResponse.fromJson(decoded);
    } catch (e) {
      rethrow;
    }
  }
}
