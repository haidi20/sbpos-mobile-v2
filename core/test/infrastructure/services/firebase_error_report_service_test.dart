import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/infrastructure/services/firebase_error_report_service.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late MockFirebaseCrashlytics mockCrashlytics;
  late FirebaseErrorReportService service;

  setUp(() {
    mockCrashlytics = MockFirebaseCrashlytics();
    service = FirebaseErrorReportService(crashlytics: mockCrashlytics);
  });

  group('FirebaseErrorReportService', () {
    test('recordError harus memanggil crashlytics.recordError', () async {
      // arrange
      final exception = Exception('test error');
      final stackTrace = StackTrace.current;
      
      when(() => mockCrashlytics.recordError(
            any(),
            any(),
            reason: any(named: 'reason'),
            fatal: any(named: 'fatal'),
          )).thenAnswer((_) async {});

      // act
      await service.recordError(exception, stackTrace, reason: 'test reason', fatal: true);

      // assert
      verify(() => mockCrashlytics.recordError(
            exception,
            stackTrace,
            reason: 'test reason',
            fatal: true,
          )).called(1);
    });

    test('setUserIdentifier harus memanggil crashlytics.setUserIdentifier', () async {
      // arrange
      const userId = 'user-123';
      when(() => mockCrashlytics.setUserIdentifier(any())).thenAnswer((_) async {});

      // act
      await service.setUserIdentifier(userId);

      // assert
      verify(() => mockCrashlytics.setUserIdentifier(userId)).called(1);
    });

    test('setCustomKey harus memanggil crashlytics.setCustomKey', () async {
      // arrange
      const key = 'test_key';
      const value = 'test_value';
      when(() => mockCrashlytics.setCustomKey(any(), any())).thenAnswer((_) async {});

      // act
      await service.setCustomKey(key, value);

      // assert
      verify(() => mockCrashlytics.setCustomKey(key, value)).called(1);
    });

    test('log harus memanggil crashlytics.log', () async {
      // arrange
      const message = 'test log message';
      when(() => mockCrashlytics.log(any())).thenAnswer((_) async {});

      // act
      await service.log(message);

      // assert
      verify(() => mockCrashlytics.log(message)).called(1);
    });
  });
}
