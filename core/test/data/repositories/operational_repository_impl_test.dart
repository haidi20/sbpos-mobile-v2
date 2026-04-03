import 'package:core/core.dart';
import 'package:core/data/datasources/operational_remote_data_source.dart';
import 'package:core/data/responses/operational_check.response.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOperationalRemoteDataSource extends OperationalRemoteDataSource {
  _FakeOperationalRemoteDataSource({
    this.onCheckServiceStatus,
    this.onCheckSubscriptionStatus,
  });

  final Future<OperationalCheckResponse> Function()? onCheckServiceStatus;
  final Future<OperationalCheckResponse> Function()? onCheckSubscriptionStatus;

  @override
  Future<OperationalCheckResponse> checkServiceStatus() {
    final handler = onCheckServiceStatus;
    if (handler == null) {
      return Future.value(
        const OperationalCheckResponse(
          success: true,
          isAllowed: true,
          message: 'OK',
        ),
      );
    }
    return handler();
  }

  @override
  Future<OperationalCheckResponse> checkSubscriptionStatus() {
    final handler = onCheckSubscriptionStatus;
    if (handler == null) {
      return Future.value(
        const OperationalCheckResponse(
          success: true,
          isAllowed: true,
          message: 'OK',
        ),
      );
    }
    return handler();
  }
}

void main() {
  group('OperationalRepositoryImpl', () {
    test('checkServiceStatus maps response to entity', () async {
      final repository = OperationalRepositoryImpl(
        remote: _FakeOperationalRemoteDataSource(
          onCheckServiceStatus: () async => const OperationalCheckResponse(
            success: true,
            isAllowed: false,
            message: 'Server dinonaktifkan',
          ),
        ),
      );

      final result = await repository.checkServiceStatus();

      result.fold(
        (_) => fail('Expected Right result'),
        (entity) {
          expect(entity.isAllowed, isFalse);
          expect(entity.message, 'Server dinonaktifkan');
        },
      );
    });

    test('checkSubscriptionStatus maps network exception to failure', () async {
      final repository = OperationalRepositoryImpl(
        remote: _FakeOperationalRemoteDataSource(
          onCheckSubscriptionStatus: () => Future.error(NetworkException()),
        ),
      );

      final result = await repository.checkSubscriptionStatus();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left result'),
      );
    });
  });
}
