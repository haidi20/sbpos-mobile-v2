import 'package:core/core.dart';
import 'package:product/data/responses/product.response.dart';

class ProductRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  ProductRemoteDataSource({String? host, String? api, ApiHelper? apiHelper})
      : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<ProductResponse> fetchProducts({Map<String, dynamic>? params}) async {
    final response = await handleApiResponse(() async =>
        _apiHelper.get(url: '$host/$api/products', params: params ?? {}));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductResponse.fromJson(decoded);
  }

  Future<ProductResponse> postProduct(Map<String, dynamic> payload) async {
    final response = await handleApiResponse(
        () async => _apiHelper.post(url: '$host/$api/products', body: payload));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductResponse.fromJson(decoded);
  }

  Future<ProductResponse> getProduct(int id) async {
    final response = await handleApiResponse(
        () async => _apiHelper.get(url: '$host/$api/products/$id'));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductResponse.fromJson(decoded);
  }

  Future<ProductResponse> updateProduct(
      int id, Map<String, dynamic> payload) async {
    final response = await handleApiResponse(() async =>
        _apiHelper.put(url: '$host/$api/products/$id', body: payload));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductResponse.fromJson(decoded);
  }

  Future<ProductResponse> deleteProduct(int id) async {
    final response = await handleApiResponse(
        () async => _apiHelper.delete(url: '$host/$api/products/$id'));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductResponse.fromJson(decoded);
  }
}
