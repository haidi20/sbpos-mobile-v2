import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:core/utils/helpers/failure.dart';
import 'package:http/http.dart' as http;

const bool _showPrint = false;

/// Helper untuk menangani request HTTP dan exception
Future<http.Response> handleApiResponse(
  Future<http.Response> Function() apiCall,
) async {
  try {
    if (_showPrint) print('🚀 Starting API call...');
    final response = await apiCall();
    if (_showPrint) print('📥 Response received: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (_showPrint) print('✅ Success response: ${response.statusCode}');
      return response;
    } else {
      if (_showPrint) print('❌ Error response: ${response.statusCode}');
      final message = _extractMessage(response);
      if (_showPrint) print('📝 Error message: $message');
      throw ServerException(message);
    }
  } on SocketException {
    if (_showPrint) print('🔌 Network error: No internet connection');
    throw NetworkException('Tidak ada koneksi internet.');
  } on TimeoutException {
    if (_showPrint) print('⏰ Timeout error: Request timed out');
    throw NetworkException('Waktu permintaan habis.');
  } catch (e) {
    if (_showPrint) print('💥 Unexpected error: ${e.toString()}');
    if (e is Failure) rethrow;
    throw ServerException(e.toString());
  }
}

String _extractMessage(http.Response response) {
  try {
    if (_showPrint) print('📝 Extracting message from response...');
    final body = jsonDecode(response.body);
    if (body is Map && body.containsKey('message')) {
      final msg = body['message'];
      if (_showPrint) print('📤 Extracted message: $msg');
      if (msg is String) return msg;
      return msg.toString();
    }
  } catch (e) {
    print('❌ Error extracting message: ${e.toString()}');
  }
  return 'Kesalahan server (${response.statusCode})';
}
