import 'dart:io' if (dart.library.html) 'package:core/utils/io_stub.dart';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class CoreRemoteDataSource with BaseErrorHelper {
  CoreRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  final String host;
  final String api;
  final ApiHelper _apiHelper;

  Future<AuthResponse> login({
    String? email,
    String? password,
  }) async {
    try {
      final response = await _apiHelper.post(
        url: '$host/$api/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      await _writeResponseToFile(response);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(decoded);
      }

      if (response.statusCode == 401) {
        return AuthResponse(
          user: null,
          token: null,
          refreshToken: null,
        );
      }

      final errorMessage = decoded['message'] ?? 'Terjadi kesalahan server';
      throw ServerException(errorMessage.toString());
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiHelper.post(
        url: '$host/$api/refresh-token',
        body: {
          'refresh_token': refreshToken,
        },
      );

      await _writeResponseToFile(response);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(decoded);
      }

      if (response.statusCode == 401) {
        throw const ServerValidation('Sesi login telah berakhir');
      }

      final errorMessage = decoded['message'] ?? 'Terjadi kesalahan server';
      throw ServerException(errorMessage.toString());
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<AuthResponse?> logout({
    String? deviceToken,
  }) async {
    try {
      final response = await _apiHelper.post(
        url: '$host/$api/logout',
        body: {
          'token': deviceToken ?? '',
        },
      );

      await _writeResponseToFile(response);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(decoded);
      }

      if (response.statusCode == 401) {
        return AuthResponse(
          user: null,
          token: null,
          refreshToken: null,
        );
      }

      final errorMessage = decoded['message'] ?? 'Terjadi kesalahan server';
      throw ServerException(errorMessage.toString());
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> _writeResponseToFile(dynamic response) async {
    if (!kDebugMode) return;

    try {
      final dir = await getApplicationDocumentsDirectory() as dynamic;
      if (dir == null) return;
      final filePath = '${dir.path}/response_api.json';
      final file = File(filePath);
      await file.writeAsString(response.body, flush: true);
    } catch (_) {}
  }
}
