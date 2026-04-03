import 'package:core/core.dart';
import 'package:core/domain/usecases/check_service_status.dart';
import 'package:core/domain/usecases/check_subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOperationalRepository implements OperationalRepository {
  _FakeOperationalRepository({
    required this.serviceResult,
    required this.subscriptionResult,
  });

  Either<Failure, OperationalCheckEntity> serviceResult;
  Either<Failure, OperationalCheckEntity> subscriptionResult;

  @override
  Future<Either<Failure, OperationalCheckEntity>> checkServiceStatus() async =>
      serviceResult;

  @override
  Future<Either<Failure, OperationalCheckEntity>> checkSubscriptionStatus() async =>
      subscriptionResult;
}

void main() {
  test('refreshStatus blocks app when service check returns false', () async {
    final repository = _FakeOperationalRepository(
      serviceResult: const Right(
        OperationalCheckEntity(
          isAllowed: false,
          message: 'Tagihan server belum dibayar',
        ),
      ),
      subscriptionResult: const Right(
        OperationalCheckEntity(
          isAllowed: true,
          message: 'Langganan aktif',
        ),
      ),
    );
    final viewModel = OperationalStatusViewModel(
      CheckServiceStatus(repository),
      CheckSubscriptionStatus(repository),
    );

    await viewModel.refreshStatus();

    expect(viewModel.state.isBlocked, isTrue);
    expect(viewModel.state.blockTitle, 'Layanan POS Tidak Aktif');
    expect(viewModel.state.blockMessage, 'Tagihan server belum dibayar');
  });

  test('refreshStatus keeps app unblocked when checks fail unexpectedly',
      () async {
    final repository = _FakeOperationalRepository(
      serviceResult: const Left(NetworkFailure()),
      subscriptionResult: const Left(ServerFailure()),
    );
    final viewModel = OperationalStatusViewModel(
      CheckServiceStatus(repository),
      CheckSubscriptionStatus(repository),
    );

    await viewModel.refreshStatus();

    expect(viewModel.state.isBlocked, isFalse);
    expect(viewModel.state.errorMessage, isNotEmpty);
  });
}
