import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:core/domain/services/error_report_service.dart';

/// Implementasi [ErrorReportService] menggunakan Firebase Crashlytics.
class FirebaseErrorReportService implements ErrorReportService {
  final FirebaseCrashlytics _crashlytics;

  FirebaseErrorReportService({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    // Hanya laporkan jika tidak dalam mode debug (opsional, tergantung kebijakan)
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
}
