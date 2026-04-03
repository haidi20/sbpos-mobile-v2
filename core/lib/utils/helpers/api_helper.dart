import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.html) 'package:core/utils/io_stub.dart';

import 'package:core/data/datasources/core_local_data_source.dart';
import 'package:core/data/models/user_model.dart';
import 'package:core/utils/constans/constan.dart';
import 'package:core/utils/helpers/api_exeption.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:path/path.dart';

class ApiHelper {
  static ApiHelper? _apiHelper;
  static dynamic _apiClient;
  static Completer<bool>? _refreshCompleter;

  UserModel? getUserLogin;
  final CoreLocalDataSource _localDataSource = CoreLocalDataSource();

  ApiHelper._instance() {
    _apiHelper = this;
  }

  factory ApiHelper() => _apiHelper ?? ApiHelper._instance();

  Future<dynamic> get apiClient async {
    _apiClient ??= await _initClient();
    return _apiClient;
  }

  Future<dynamic> _initClient() async {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => false;
    return client;
  }

  Future<String> _readAccessToken() async {
    getUserLogin = await _localDataSource.getUser();
    return getUserLogin?.token ?? '';
  }

  Map<String, String> _buildHeaders({
    required String token,
    bool withJsonHeaders = false,
  }) {
    final headers = <String, String>{};
    if (withJsonHeaders) {
      headers['Accept'] = 'application/json';
      headers['Content-Type'] = 'application/json';
    }
    if (token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return headers;
  }

  bool _isAuthenticationEndpoint(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/login') || lower.contains('/refresh-token');
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final currentUser = await _localDataSource.getUser();
      final refreshToken = currentUser?.refreshToken ?? '';
      if (refreshToken.isEmpty) {
        completer.complete(false);
        return completer.future;
      }

      final client = await apiClient;
      final ioClient = IOClient(client);
      final response = await ioClient.post(
        Uri.parse('$HOST/$API/refresh-token'),
        body: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode != 200) {
        try {
          await _localDataSource.deleteToken();
        } catch (_) {}
        completer.complete(false);
        return completer.future;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccessToken = decoded['access_token'] as String?;
      final newRefreshToken =
          (decoded['refresh_token'] as String?) ?? refreshToken;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        completer.complete(false);
        return completer.future;
      }

      final responseUser = decoded['user'] as Map<String, dynamic>?;
      final updatedUser = (responseUser != null
              ? UserModel.fromJson({
                  ...responseUser,
                  'token': newAccessToken,
                  'refresh_token': newRefreshToken,
                  'password': currentUser?.password,
                })
              : (currentUser ?? UserModel()).copyWith(
                  token: newAccessToken,
                  refreshToken: newRefreshToken,
                  lastLogin: DateTime.now(),
                ))
          .copyWith(
        password: currentUser?.password,
        lastLogin: DateTime.now(),
      );

      await _localDataSource.storeUser(user: updatedUser);
      completer.complete(true);
      return completer.future;
    } catch (_) {
      completer.complete(false);
      return completer.future;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<http.Response> _sendAuthorizedRequest({
    required String url,
    required Future<http.Response> Function(
      IOClient client,
      Map<String, String> headers,
    ) send,
    bool withJsonHeaders = false,
    bool allowRefresh = true,
  }) async {
    final client = await apiClient;
    final ioClient = IOClient(client);
    final token = await _readAccessToken();
    final headers = _buildHeaders(
      token: token,
      withJsonHeaders: withJsonHeaders,
    );

    final response = await send(ioClient, headers);
    final canRefresh =
        allowRefresh && !_isAuthenticationEndpoint(url) && response.statusCode == 401;

    if (!canRefresh) {
      return response;
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      return response;
    }

    final retryToken = await _readAccessToken();
    final retryHeaders = _buildHeaders(
      token: retryToken,
      withJsonHeaders: withJsonHeaders,
    );
    return send(ioClient, retryHeaders);
  }

  Future<http.Response> get({
    required String url,
    Map<String, dynamic>? params,
  }) async {
    final urlFinal = Uri.parse(url).replace(
      queryParameters:
          params?.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );

    return _sendAuthorizedRequest(
      url: url,
      withJsonHeaders: true,
      send: (ioClient, headers) => ioClient.get(urlFinal, headers: headers),
    );
  }

  Future<http.Response> post({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _sendAuthorizedRequest(
      url: url,
      send: (ioClient, headers) => ioClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ),
    );
  }

  Future<http.Response> put({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _sendAuthorizedRequest(
      url: url,
      send: (ioClient, headers) => ioClient.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      ),
    );
  }

  Future<http.StreamedResponse> postWithImage({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    getUserLogin = await _localDataSource.getUser();
    final token = getUserLogin?.token ?? '';

    for (var entry in body.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          final item = value[i];
          item.toJson().forEach((nestedKey, nestedValue) {
            if (nestedKey != 'image_file') {
              request.fields['$key[$i][$nestedKey]'] = jsonEncode(nestedValue);
            }
          });

          if (item.imageFile != null) {
            request.fields['$key[$i][image_status]'] = 'ada image';
            final imageFile = item.imageFile!;
            if (imageFile.existsSync()) {
              request.files.add(await http.MultipartFile.fromPath(
                '$key[$i][image]',
                imageFile.path,
                filename: basename(imageFile.path),
              ));

              request.fields['$key[$i][image_path]'] = imageFile.path;
            }
          } else {
            request.fields['$key[$i][image_status]'] = 'tidak ada image';
          }
        }
      } else {
        if (value is File && value.existsSync()) {
          request.fields['image_status'] = 'ada image';
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            value.path,
            filename: basename(value.path),
          ));
          request.fields['image_path'] = value.path;
        } else if (key == 'image_file') {
          request.fields['image_status'] = 'tidak ada image';
        } else {
          request.fields[key] = value is String ? value : jsonEncode(value);
        }
      }
    }

    final client = await apiClient;
    final ioClient = IOClient(client);

    if (token.isNotEmpty) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    return ioClient.send(request);
  }

  Future<http.StreamedResponse> postWithImageList({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    getUserLogin = await _localDataSource.getUser();
    final token = getUserLogin?.token ?? '';

    for (var entry in body.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value.runtimeType.toString().contains('Model')) {
        if (value != null && value.toJson is Function) {
          value.toJson().forEach((nestedKey, nestedValue) {
            if (nestedKey != 'images' && nestedKey != 'imageServers') {
              request.fields['$key[$nestedKey]'] =
                  nestedValue?.toString() ?? '';
            }
          });

          if (value.images != null && value.images is List) {
            for (int i = 0; i < value.images.length; i++) {
              final imagePath = value.images[i];
              final imageFile = File(imagePath);
              if (imageFile.existsSync()) {
                request.files.add(await http.MultipartFile.fromPath(
                  '$key[images][$i]',
                  imageFile.path,
                  filename: basename(imageFile.path),
                ));
              }
            }
          }
        }
      } else if (value is List) {
        //
      } else {
        if (value is File && value.existsSync()) {
          request.fields['image_status'] = 'ada image';
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            value.path,
            filename: basename(value.path),
          ));
          request.fields['image_path'] = value.path;
        } else if (key == 'image_file') {
          request.fields['image_status'] = 'tidak ada image';
        } else {
          request.fields[key] = value is String ? value : jsonEncode(value);
        }
      }
    }

    final client = await apiClient;
    final ioClient = IOClient(client);

    if (token.isNotEmpty) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    return ioClient.send(request);
  }

  Future<dynamic> uploadFileCustom({
    var url,
    var body,
    required File file,
    String? paramFile = '',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      getUserLogin = await _localDataSource.getUser();
      final token = getUserLogin?.token ?? '';

      if (body != null) {
        request.fields.addAll(body);
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          '$paramFile',
          file.path,
        ),
      );

      if (token.isNotEmpty) {
        request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }

      return request.send();
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException(
        'API not responded in time',
        url.toString(),
      );
    } catch (e) {
      debugPrint('Error occured with code : $e');
    }
  }

  Future<http.Response> delete({
    var url,
    final headers,
    var body,
  }) async {
    try {
      return _sendAuthorizedRequest(
        url: url.toString(),
        withJsonHeaders: true,
        send: (ioClient, resolvedHeaders) => ioClient
            .delete(
              Uri.parse(url),
              headers: resolvedHeaders,
              body: body,
            )
            .timeout(const Duration(seconds: 60)),
      );
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException(
        'API not responded in time',
        url.toString(),
      );
    }
  }
}
