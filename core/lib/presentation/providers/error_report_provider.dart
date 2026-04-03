import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:core/domain/services/error_report_service.dart';
import 'package:core/infrastructure/services/firebase_error_report_service.dart';

/// Provider untuk [ErrorReportService].
/// Secara default menggunakan [FirebaseErrorReportService].
final errorReportServiceProvider = Provider<ErrorReportService>((ref) {
  return FirebaseErrorReportService(
    crashlytics: FirebaseCrashlytics.instance,
  );
});
