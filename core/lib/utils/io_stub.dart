/// Stub IO minimal untuk build web agar tidak perlu mengimpor `dart:io`.
class File {
  final String path;
  File(this.path);

  Future<void> writeAsString(String content, {bool flush = false}) async {}
  Future<bool> exists() async => false;
  bool existsSync() => false;
}

/// Stub HttpClient minimal yang digunakan oleh `ApiHelper` pada build web.
class HttpClient {
  bool Function(Object? cert, String host, int port)? badCertificateCallback;
  HttpClient();
}

/// Stub X509Certificate minimal
class X509Certificate {}

/// Stub HttpHeaders minimal
class HttpHeaders {
  static const String authorizationHeader = 'authorization';
}

/// Stub SocketException minimal
class SocketException implements Exception {
  final String message;
  SocketException([this.message = '']);
  @override
  String toString() => 'SocketException: $message';
}
