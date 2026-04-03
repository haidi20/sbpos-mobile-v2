import 'package:core/core.dart';
import 'package:core/domain/usecases/check_service_status.dart';
import 'package:core/domain/usecases/check_subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOperationalRepository implements OperationalRepository {
  _FakeOperationalRepository({
    this.onCheckServiceStatus,
    this.onCheckSubscriptionStatus,
  });

  final Future<Either<Failure, OperationalCheckEntity>> Function()?
      onCheckServiceStatus;
  final Future<Either<Failure, OperationalCheckEntity>> Function()?
      onCheckSubscriptionStatus;

  @override
  Future<Either<Failure, OperationalCheckEntity>> checkServiceStatus() {
    final handler = onCheckServiceStatus;
    if (handler == null) {
      return Future.value(
        const Right(
          OperationalCheckEntity(
            isAllowed: true,
            message: 'Layanan aktif',
          ),
        ),
      );
    }
    return handler();
  }

  @override
  Future<Either<Failure, OperationalCheckEntity>> checkSubscriptionStatus() {
    final handler = onCheckSubscriptionStatus;
    if (handler == null) {
      return Future.value(
        const Right(
          OperationalCheckEntity(
            isAllowed: true,
            message: 'Langganan aktif',
          ),
        ),
      );
    }
    return handler();
  }
}

void main() {
  group('CheckServiceStatus', () {
    test('returns repository result on success', () async {
      final usecase = CheckServiceStatus(
        _FakeOperationalRepository(),
      );

      final result = await usecase();

      result.fold(
        (_) => fail('Expected Right result'),
        (entity) => expect(entity.isAllowed, isTrue),
      );
    });

    test('maps thrown exception to UnknownFailure', () async {
      final usecase = CheckServiceStatus(
        _FakeOperationalRepository(
          onCheckServiceStatus: () => Future.error(Exception('boom')),
        ),
      );

      final result = await usecase();

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left result'),
      );
    });
  });

  group('CheckSubscriptionStatus', () {
    test('returns repository failure unchanged', () async {
      final usecase = CheckSubscriptionStatus(
        _FakeOperationalRepository(
          onCheckSubscriptionStatus: () async =>
              const Left(ServerValidation('Langganan habis')),
        ),
      );

      final result = await usecase();

      result.fold(
        (failure) => expect(failure, isA<ServerValidation>()),
        (_) => fail('Expected Left result'),
      );
    });
  });
}
