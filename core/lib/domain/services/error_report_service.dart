abstract class ErrorReportService {
  /// Melaporkan error/exception ke layanan eksternal (misal: Firebase Crashlytics).
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  });

  /// Menandai laporan dengan identitas user tertentu.
  Future<void> setUserIdentifier(String identifier);

  /// Menambahkan kunci kustom untuk konteks tambahan pada laporan error.
  Future<void> setCustomKey(String key, dynamic value);

  /// Menambahkan log pesan kustom yang akan disertakan dalam laporan error berikutnya.
  Future<void> log(String message);
}
