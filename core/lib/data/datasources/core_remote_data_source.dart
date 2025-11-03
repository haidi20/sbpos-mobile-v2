import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class CoreRemoteDataSource with BaseErrorHelper {
  final String host = HOST;
  final String api = API;
  final _apiHelper = ApiHelper();

  Future<AuthResponse?> login({String? username, String? password}) async {
    try {
      final response = await _apiHelper.post(
        url: '$host/$api/login',
        body: {
          'username': username,
          'password': password,
        },
      );

      await _writeResponseToFile(response);

      final decoded = jsonDecode(response.body);
      // print('core remote : $decoded');

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(decoded);
      } else if (response.statusCode == 401) {
        return AuthResponse(
          message: decoded['message'],
          success: false,
          data: null,
        );
      } else {
        final errorMessage = decoded['message'] ?? 'Terjadi kesalahan server';
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<AuthResponse?> logout() async {
    try {
      final response = await _apiHelper.post(
        url: '$host/$api/logout',
        body: {
          //
        },
      );

      await _writeResponseToFile(response);

      final decoded = jsonDecode(response.body);
      // print('core remote : $decoded');

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(decoded);
      } else if (response.statusCode == 401) {
        return AuthResponse(
          message: decoded['message'],
          success: false,
          data: null,
        );
      } else {
        final errorMessage = decoded['message'] ?? 'Terjadi kesalahan server';
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> _writeResponseToFile(dynamic response) async {
    if (!kDebugMode) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/response_api.json';
      final file = File(filePath);
      await file.writeAsString(response.body, flush: true);

      if (await file.exists()) {
        print("ada file response_api.json");
      } else {
        print('❌ Gagal menyimpan file');
      }
    } catch (e, st) {
      print('Error menyimpan file: $e\n$st');
    }
  }
}
