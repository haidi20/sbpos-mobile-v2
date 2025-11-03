// core/lib/failure/failure.dart
abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure() : super('Server sedang bermasalah. Coba lagi nanti.');
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Tidak ada koneksi internet.');
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('Terjadi kesalahan tak dikenal.');
}

// --- Exception (layer data) ---
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Terjadi kesalahan server.']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Tidak ada koneksi internet.']);
}
