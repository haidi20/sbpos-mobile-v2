import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:core/utils/helpers/failure.dart';
import 'package:http/http.dart' as http;

/// Helper untuk menangani request HTTP dan exception
Future<http.Response> handleApiResponse(
  Future<http.Response> Function() apiCall,
) async {
  try {
    final response = await apiCall();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      final message = _extractMessage(response);
      throw ServerException(message);
    }
  } on SocketException {
    throw NetworkException('Tidak ada koneksi internet.');
  } on TimeoutException {
    throw NetworkException('Waktu permintaan habis.');
  } catch (e) {
    if (e is Failure) rethrow;
    throw ServerException(e.toString());
  }
}

String _extractMessage(http.Response response) {
  try {
    final body = jsonDecode(response.body);
    if (body is Map && body.containsKey('message')) {
      final msg = body['message'];
      if (msg is String) return msg;
      return msg.toString();
    }
  } catch (_) {}
  return 'Kesalahan server (${response.statusCode})';
}
