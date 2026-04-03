import 'package:core/core.dart';
import 'package:core/domain/usecases/check_service_status.dart';
import 'package:core/domain/usecases/check_subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOperationalRepository implements OperationalRepository {
  _FakeOperationalRepository({
    required this.serviceResult,
    required this.subscriptionResult,
  });

  final Either<Failure, OperationalCheckEntity> serviceResult;
  final Either<Failure, OperationalCheckEntity> subscriptionResult;

  @override
  Future<Either<Failure, OperationalCheckEntity>> checkServiceStatus() async =>
      serviceResult;

  @override
  Future<Either<Failure, OperationalCheckEntity>> checkSubscriptionStatus() async =>
      subscriptionResult;
}

void main() {
  testWidgets('OperationalStatusGate overlays blocking screen when service is not allowed',
      (tester) async {
    final repository = _FakeOperationalRepository(
      serviceResult: const Right(
        OperationalCheckEntity(
          isAllowed: false,
          message: 'Layanan dinonaktifkan sementara',
        ),
      ),
      subscriptionResult: const Right(
        OperationalCheckEntity(
          isAllowed: true,
          message: 'Langganan aktif',
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          operationalRepositoryProvider.overrideWithValue(repository),
          checkServiceStatusProvider.overrideWithValue(
            CheckServiceStatus(repository),
          ),
          checkSubscriptionStatusProvider.overrideWithValue(
            CheckSubscriptionStatus(repository),
          ),
        ],
        child: const MaterialApp(
          home: OperationalStatusGate(
            refreshInterval: Duration(hours: 1),
            child: Scaffold(
              body: Text('POS Ready'),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('operational-status-title')), findsOneWidget);
    expect(find.text('Layanan dinonaktifkan sementara'), findsOneWidget);
    expect(find.byKey(const Key('operational-status-retry')), findsOneWidget);
  });
}
