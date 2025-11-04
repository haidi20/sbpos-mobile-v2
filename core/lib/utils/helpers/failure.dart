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

class ServerValidation implements Failure {
  @override
  final String message;
  const ServerValidation([this.message = 'Validasi server gagal.']);
}

class LocalValidation implements Failure {
  @override
  final String message;
  const LocalValidation([this.message = 'Validasi lokal gagal.']);
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

class CacheFailure extends Failure {
  const CacheFailure() : super('Terjadi kesalahan cache.');
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Terjadi kesalahan cache.']);
}
