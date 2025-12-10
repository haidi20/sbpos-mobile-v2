import 'package:core/core.dart';
import 'package:customer/data/responses/customer.response.dart';

/// Data source untuk mengambil data customer dari API remote.
/// Struktur mengikuti `transaction_remote_data_source.dart`.
class CustomerRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  CustomerRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<CustomerResponse> fetchCustomers(
      {Map<String, dynamic>? params}) async {
    try {
      final response = await handleApiResponse(() async =>
          _apiHelper.get(url: '$host/$api/customers', params: params ?? {}));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CustomerResponse.fromJson(decoded);
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerResponse> postCustomer(Map<String, dynamic> payload) async {
    try {
      final response = await handleApiResponse(() async =>
          _apiHelper.post(url: '$host/$api/customers', body: payload));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CustomerResponse.fromJson(decoded);
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerResponse> getCustomer(int id) async {
    try {
      final response = await handleApiResponse(
          () async => _apiHelper.get(url: '$host/$api/customers/$id'));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CustomerResponse.fromJson(decoded);
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerResponse> updateCustomer(
      int id, Map<String, dynamic> payload) async {
    try {
      final response = await handleApiResponse(() async =>
          _apiHelper.put(url: '$host/$api/customers/$id', body: payload));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CustomerResponse.fromJson(decoded);
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerResponse> deleteCustomer(int id) async {
    try {
      final response = await handleApiResponse(
          () async => _apiHelper.delete(url: '$host/$api/customers/$id'));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CustomerResponse.fromJson(decoded);
    } catch (e) {
      rethrow;
    }
  }
}
