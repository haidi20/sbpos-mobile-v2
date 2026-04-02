import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/data/datasources/shift_remote.data_source.dart';
import 'package:transaction/data/models/close_cashier_request.model.dart';
import 'package:transaction/data/models/open_cashier_request.model.dart';
import 'package:transaction/data/models/shift.model.dart';
import 'package:transaction/data/repositories/shift.repository_impl.dart';
import 'package:transaction/data/responses/close_cashier.response.dart';
import 'package:transaction/data/responses/close_cashier_status.response.dart';
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
  Future<OpenCashierResponseModel> Function(OpenCashierRequestModel request)?
      onOpenCashier;
  Future<CloseCashierStatusResponseModel> Function()? onGetCloseCashierStatus;
  Future<CloseCashierResponseModel> Function(CloseCashierRequestModel request)?
      onCloseCashier;

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

  @override
  Future<CloseCashierStatusResponseModel> getCloseCashierStatus() async {
    final handler = onGetCloseCashierStatus;
    if (handler == null) {
      return const CloseCashierStatusResponseModel(
        success: true,
        message: 'Kasir dapat ditutup',
        canClose: true,
        pendingOrders: 0,
      );
    }
    return handler();
  }

  @override
  Future<CloseCashierResponseModel> closeCashier(
    CloseCashierRequestModel request,
  ) async {
    final handler = onCloseCashier;
    if (handler == null) {
      return CloseCashierResponseModel(
        success: true,
        message: 'Tutup kasir berhasil',
        shift: ShiftModel(
          idServer: 2,
          shiftNumber: 1,
          closingBalance: request.cashInDrawer,
          isClosed: true,
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

  test('getCloseCashierStatus mengembalikan entity saat remote sukses',
      () async {
    final result = await repository.getCloseCashierStatus();

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) {
        expect(entity.canClose, isTrue);
        expect(entity.pendingOrders, equals(0));
        expect(entity.message, equals('Kasir dapat ditutup'));
      },
    );
  });

  test('getCloseCashierStatus memetakan ServerException ke ServerFailure',
      () async {
    remote.onGetCloseCashierStatus = () =>
        Future.error(ServerException('server'));

    final result = await repository.getCloseCashierStatus();

    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('closeCashier mengembalikan shift tertutup saat remote sukses',
      () async {
    final result = await repository.closeCashier(500000);

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) {
        expect(entity.isOpen, isFalse);
        expect(entity.shift?.closingBalance, equals(500000));
        expect(entity.shift?.isClosed, isTrue);
        expect(entity.message, equals('Tutup kasir berhasil'));
      },
    );
  });

  test('closeCashier memetakan NetworkException ke NetworkFailure', () async {
    remote.onCloseCashier = (request) =>
        Future.error(NetworkException('offline'));

    final result = await repository.closeCashier(500000);

    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('closeCashier memetakan error tak terduga ke UnknownFailure', () async {
    remote.onCloseCashier = (request) => Future.error(Exception('boom'));

    final result = await repository.closeCashier(500000);

    result.fold(
      (failure) => expect(failure, isA<UnknownFailure>()),
      (_) => fail('Expected Left result'),
    );
  });
}
