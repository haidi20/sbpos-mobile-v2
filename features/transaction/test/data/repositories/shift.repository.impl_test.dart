import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/data/datasources/shift_remote.data_source.dart';
import 'package:transaction/data/models/open_cashier_request.model.dart';
import 'package:transaction/data/models/shift.model.dart';
import 'package:transaction/data/repositories/shift.repository_impl.dart';
import 'package:transaction/data/responses/open_cashier.response.dart';
import 'package:transaction/data/responses/shift_status.response.dart';

class _FakeShiftRemoteDataSource extends ShiftRemoteDataSource {
  _FakeShiftRemoteDataSource()
      : super(
          host: 'https://example.com',
          api: 'api',
          apiHelper: ApiHelper(),
        );

  Future<ShiftStatusResponseModel> Function()? onGetShiftStatus;
  Future<ShiftModel?> Function()? onGetLatestShift;
  Future<OpenCashierResponseModel> Function(OpenCashierRequestModel request)?
      onOpenCashier;

  @override
  Future<ShiftStatusResponseModel> getShiftStatus() async {
    final handler = onGetShiftStatus;
    if (handler == null) {
      return const ShiftStatusResponseModel(
        success: true,
        message: 'Shift belum dibuka',
        isOpen: false,
      );
    }
    return handler();
  }

  @override
  Future<ShiftModel?> getLatestShift() async {
    final handler = onGetLatestShift;
    if (handler == null) {
      return ShiftModel(
        idServer: 5,
        shiftNumber: 3,
        openingBalance: 150000,
      );
    }
    return handler();
  }

  @override
  Future<OpenCashierResponseModel> openCashier(
    OpenCashierRequestModel request,
  ) async {
    final handler = onOpenCashier;
    if (handler == null) {
      return OpenCashierResponseModel(
        success: true,
        message: 'Buka kasir berhasil',
        shift: ShiftModel(
          idServer: 1,
          shiftNumber: 1,
          openingBalance: request.initialBalance,
          isClosed: false,
        ),
      );
    }
    return handler(request);
  }
}

void main() {
  late _FakeShiftRemoteDataSource remote;
  late ShiftRepositoryImpl repository;

  setUp(() {
    remote = _FakeShiftRemoteDataSource();
    repository = ShiftRepositoryImpl(remote: remote);
  });

  test('getShiftStatus mengembalikan entity saat remote sukses', () async {
    final result = await repository.getShiftStatus();

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) {
        expect(entity.isOpen, isFalse);
        expect(entity.message, equals('Shift belum dibuka'));
      },
    );
  });

  test('getShiftStatus memetakan ServerException ke ServerFailure', () async {
    remote.onGetShiftStatus = () => Future.error(ServerException('server'));

    final result = await repository.getShiftStatus();

    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('openCashier mengembalikan entity terbuka saat remote sukses', () async {
    final result = await repository.openCashier(250000);

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) {
        expect(entity.isOpen, isTrue);
        expect(entity.shift?.openingBalance, equals(250000));
        expect(entity.message, equals('Buka kasir berhasil'));
      },
    );
  });

  test('getLatestShift mengembalikan shift entity saat remote sukses', () async {
    final result = await repository.getLatestShift();

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) {
        expect(entity?.shiftNumber, equals(3));
        expect(entity?.openingBalance, equals(150000));
      },
    );
  });

  test('openCashier memetakan NetworkException ke NetworkFailure', () async {
    remote.onOpenCashier = (request) =>
        Future.error(NetworkException('offline'));

    final result = await repository.openCashier(250000);

    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('openCashier memetakan error tak terduga ke UnknownFailure', () async {
    remote.onOpenCashier = (request) => Future.error(Exception('boom'));

    final result = await repository.openCashier(250000);

    result.fold(
      (failure) => expect(failure, isA<UnknownFailure>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('getLatestShift memetakan error tak terduga ke UnknownFailure',
      () async {
    remote.onGetLatestShift = () => Future.error(Exception('boom'));

    final result = await repository.getLatestShift();

    result.fold(
      (failure) => expect(failure, isA<UnknownFailure>()),
      (_) => fail('Expected Left result'),
    );
  });
}
