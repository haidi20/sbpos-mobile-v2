import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:product/data/responses/cart_response.dart';

class CartRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;

  CartRemoteDataSource({String? host, String? api, ApiHelper? apiHelper})
      : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<CartResponse> fetchCarts() async {
    final response = await handleApiResponse(
        () async => _apiHelper.get(url: '$host/$api/carts', params: {}));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return CartResponse.fromJson(decoded);
  }

  Future<void> _writeResponseToFile(dynamic response) async {
    if (!kDebugMode) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/response_cart.json';
      final file = File(filePath);
      await file.writeAsString(response.body, flush: true);
    } catch (e, st) {
      print('Error menyimpan file: $e\n$st');
    }
  }
}
