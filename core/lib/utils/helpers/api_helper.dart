import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) 'package:core/utils/io_stub.dart';
import 'package:path/path.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:core/data/models/user_model.dart';
import 'package:core/utils/helpers/api_exeption.dart';
import 'package:core/data/datasources/core_local_data_source.dart';

class ApiHelper {
  static ApiHelper? _apiHelper;
  UserModel? getUserLogin;
  final CoreLocalDataSource _localDataSource = CoreLocalDataSource();
  ApiHelper._instance() {
    _apiHelper = this;
  }

  factory ApiHelper() => _apiHelper ?? ApiHelper._instance();

  static dynamic _apiClient;

  Future<dynamic> get apiClient async {
    _apiClient ??= await _initClient();
    return _apiClient;
  }

  Future<dynamic> _initClient() async {
    final client = HttpClient();
    // Gunakan parameter tanpa tipe untuk menghindari kesalahan tanda tangan
    // antara dart:io X509Certificate dan X509Certificate pada io_stub web.
    client.badCertificateCallback = (cert, host, port) => false;
    return client;
  }

  Future<http.Response> get({
    required String url,
    Map<String, dynamic>? params,
  }) async {
    final client = await apiClient; // Ensure apiClient is defined
    final ioClient = IOClient(client);

    // Menambahkan user_id ke dalam params jika ada
    // final userId = storage.read(USER_ID);
    // UserInfoModel getUserInfo = await UserInfo().getUserInfo();
    // if (getUserInfo.userId != 0) {
    // params ??= {}; // Inisialisasi params jika null
    // params.addAll(getUserInfo.toMap());
    // }

    getUserLogin = await _localDataSource.getUser();
    final token = getUserLogin?.token ?? "";

    // Menyiapkan URL dengan parameter pencarian
    final Uri urlFinal = Uri.parse(url).replace(
      queryParameters:
          params?.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );

    // print("apiToken: ${getUserInfo.getUser?.apiToken}");

    // Menyiapkan header
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      // "Authorization": "Bearer ${storage.read(TOKEN_ACCESS)}",
      "Authorization": "Bearer $token",
    };

    // Mengirimkan request dengan header
    final response = await ioClient.get(urlFinal, headers: headers);

    return response;
  }

  Future<http.Response> post({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final client = await apiClient; // Memastikan apiClient didefinisikan
    final ioClient = IOClient(client);

    getUserLogin = await _localDataSource.getUser();
    final token = getUserLogin?.token ?? "";

    // print("api helper token = $token");

    // Menyiapkan header
    final headers = {
      // "Content-Type": "application/json",
      // "Accept": "application/json",
      // "Authorization": "Bearer ${storage.read(TOKEN_ACCESS)}",
      HttpHeaders.authorizationHeader: "Bearer $token",
      // "Authorization": "Bearer $token",
    };

    // Mengirimkan request POST dengan header dan body
    final response = await ioClient.post(
      Uri.parse(url),
      headers: headers,
      // body: jsonEncode(body), // Convert body ke JSON string
      body: body,
    );

    return response;
  }

  Future<http.Response> put({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final client = await apiClient; // Memastikan apiClient didefinisikan
    final ioClient = IOClient(client);

    getUserLogin = await _localDataSource.getUser();
    final token = getUserLogin?.token ?? "";

    final headers = {
      HttpHeaders.authorizationHeader: "Bearer $token",
    };

    final response = await ioClient.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return response;
  }

  Future<http.StreamedResponse> postWithImage({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    getUserLogin = await _localDataSource.getUser();
    final token = getUserLogin?.token ?? "";

    // Loop untuk setiap key-value pair dalam body
    for (var entry in body.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is List) {
        // Jika value adalah array, loop untuk setiap elemen
        for (int i = 0; i < value.length; i++) {
          final item = value[i];
          item.toJson().forEach((nestedKey, nestedValue) {
            if (nestedKey != "image_file") {
              debugPrint("bukan image_file");
              request.fields['$key[$i][$nestedKey]'] = jsonEncode(nestedValue);
            }
          });

          // Jika ada image_file, tambahkan ke files
          if (item.imageFile != null) {
            request.fields['$key[$i][image_status]'] = "ada image";
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
            request.fields['$key[$i][image_status]'] = "tidak ada image";
          }
        }
      } else {
        // print(" key = $key & value = $value");
        if (value is File && value.existsSync()) {
          debugPrint("ada image_file");
          request.fields['image_status'] = "ada image";
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            value.path,
            filename: basename(value.path),
          ));
          request.fields['image_path'] = value.path;
        } else if (key == "image_file") {
          // image_file tapi nilainya null
          request.fields['image_status'] = "tidak ada image";
        } else {
          // Bukan image_file
          request.fields[key] = value is String ? value : jsonEncode(value);
        }
      }
    }

    final client =
        await apiClient; // Pastikan `apiClient` didefinisikan dengan benar
    final ioClient = IOClient(client);

    // Tambahkan header Authorization
    final header = {
      // "Authorization": "Bearer ${storage.read(TOKEN_ACCESS)}",
      "Authorization": "Bearer $token",
    };

    // Set header pada request
    request.headers.addAll(header);

    // print(request.fields);

    // Kirim request
    final response = await ioClient.send(request);

    return response;
  }

  Future<http.StreamedResponse> postWithImageList({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    getUserLogin = await _localDataSource.getUser();
    final token = getUserLogin?.token ?? "";

    for (var entry in body.entries) {
      final key = entry.key;
      final value = entry.value;

      // print("value = $value");
      // print("key: $key, type: ${value.runtimeType}");

      if (value.runtimeType.toString().contains('Model')) {
        // Deteksi jika value adalah model dengan adanya toJson method
        if (value != null && value.toJson is Function) {
          // Add model fields except images
          value.toJson().forEach((nestedKey, nestedValue) {
            if (nestedKey != "images" && nestedKey != "imageServers") {
              request.fields['$key[$nestedKey]'] =
                  nestedValue?.toString() ?? '';
            }
          });

          // Add image files if present
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
        // print(" key = $key & value = $value");
        if (value is File && value.existsSync()) {
          debugPrint("ada image_file");
          request.fields['image_status'] = "ada image";
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            value.path,
            filename: basename(value.path),
          ));
          request.fields['image_path'] = value.path;
        } else if (key == "image_file") {
          // image_file tapi nilainya null
          request.fields['image_status'] = "tidak ada image";
        } else {
          // Bukan image_file
          request.fields[key] = value is String ? value : jsonEncode(value);
        }
      }
    }

    final client = await apiClient;
    final ioClient = IOClient(client);

    final header = {
      "Authorization": "Bearer $token",
    };
    request.headers.addAll(header);

    final response = await ioClient.send(request);
    return response;
  }

  Future<dynamic> uploadFileCustom({
    var url,
    var body,
    required File file,
    String? paramFile = "",
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      getUserLogin = await _localDataSource.getUser();
      final token = getUserLogin?.token ?? "";

      if (body != null) {
        request.fields.addAll(body);
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          '$paramFile',
          file.path,
          // filename: file.path.split('/').last,
        ),
      );

      final header = {
        "Content-Type": "multipart/form-data",
        // "Authorization": "Bearer ${storage.read(TOKEN_ACCESS)}",
        "Authorization": "Bearer $token",
      };

      request.headers.addAll(header);
      http.StreamedResponse response = await request.send();

      // listen for response

      return response;
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', url.toString());
    } catch (e) {
      debugPrint('Error occured with code : $e');
    }
  }

  // delete
  Future<http.Response> delete({
    var url,
    final headers,
    var body,
  }) async {
    try {
      getUserLogin = await _localDataSource.getUser();
      final token = getUserLogin?.token ?? "";

      final header = {
        "Content-Type": "application/json",
        // "Authorization": "Bearer ${storage.read(TOKEN_ACCESS)}",
        "Authorization": "Bearer $token",
      };

      final response = await http
          .delete(Uri.parse(url), headers: header, body: body)
          .timeout(const Duration(seconds: 60));
      return response;
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', url.toString());
    }
  }
}
