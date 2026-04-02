import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';
import 'package:transaction/domain/usecases/get_latest_shift.usecase.dart';
import 'package:transaction/domain/usecases/get_shift_status.usecase.dart';
import 'package:transaction/domain/usecases/open_cashier.usecase.dart';

class _FakeShiftRepository implements ShiftRepository {
  Future<Either<Failure, ShiftStatusEntity>> Function()? onGetShiftStatus;
  Future<Either<Failure, ShiftEntity?>> Function()? onGetLatestShift;
  Future<Either<Failure, ShiftStatusEntity>> Function(int balance)?
      onOpenCashier;
  Future<Either<Failure, CloseCashierStatusEntity>> Function()?
      onGetCloseCashierStatus;
  Future<Either<Failure, ShiftStatusEntity>> Function(int cashInDrawer)?
      onCloseCashier;

  @override
  Future<Either<Failure, ShiftStatusEntity>> getShiftStatus() {
    final handler = onGetShiftStatus;
    if (handler == null) {
      return Future.value(
        const Right(
          ShiftStatusEntity(
            isOpen: false,
            message: 'Shift belum dibuka',
          ),
        ),
      );
    }
    return handler();
  }

  @override
  Future<Either<Failure, ShiftEntity?>> getLatestShift() {
    final handler = onGetLatestShift;
    if (handler == null) {
      return Future.value(
        Right(
          ShiftEntity(
            openingBalance: 120000,
            shiftNumber: 2,
          ),
        ),
      );
    }
    return handler();
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> openCashier(int initialBalance) {
    final handler = onOpenCashier;
    if (handler == null) {
      return Future.value(
        Right(
          ShiftStatusEntity(
            isOpen: true,
            message: 'Buka kasir berhasil',
            shift: ShiftEntity(openingBalance: initialBalance),
          ),
        ),
      );
    }
    return handler(initialBalance);
  }

  @override
  Future<Either<Failure, CloseCashierStatusEntity>> getCloseCashierStatus() {
    final handler = onGetCloseCashierStatus;
    if (handler == null) {
      return Future.value(
        const Right(
          CloseCashierStatusEntity(
            canClose: true,
            message: 'Kasir dapat ditutup',
            pendingOrders: 0,
          ),
        ),
      );
    }
    return handler();
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> closeCashier(int cashInDrawer) {
    final handler = onCloseCashier;
    if (handler == null) {
      return Future.value(
        Right(
          ShiftStatusEntity(
            isOpen: false,
            message: 'Tutup kasir berhasil',
            shift: ShiftEntity(
              closingBalance: cashInDrawer,
              isClosed: true,
            ),
          ),
        ),
      );
    }
    return handler(cashInDrawer);
  }
}

void main() {
  late _FakeShiftRepository repository;

  setUp(() {
    repository = _FakeShiftRepository();
  });

  test('GetShiftStatus mengembalikan entity saat sukses', () async {
    final result = await GetShiftStatus(repository)();

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) => expect(entity.isOpen, isFalse),
    );
  });

  test('GetShiftStatus memetakan thrown Failure ke Left', () async {
    const failure = NetworkFailure();
    repository.onGetShiftStatus = () => Future.error(failure);

    final result = await GetShiftStatus(repository)();

    result.fold(
      (value) => expect(value, same(failure)),
      (_) => fail('Expected Left result'),
    );
  });

  test('GetShiftStatus memetakan exception tak terduga ke UnknownFailure',
      () async {
    repository.onGetShiftStatus = () => Future.error(Exception('boom'));

    final result = await GetShiftStatus(repository)();

    result.fold(
      (value) => expect(value, isA<UnknownFailure>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('OpenCashier mengembalikan entity terbuka saat sukses', () async {
    final result = await OpenCashier(repository)(250000);

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) {
        expect(entity.isOpen, isTrue);
        expect(entity.shift?.openingBalance, equals(250000));
      },
    );
  });

  test('OpenCashier memetakan thrown Failure ke Left', () async {
    const failure = ServerFailure();
    repository.onOpenCashier = (balance) => Future.error(failure);

    final result = await OpenCashier(repository)(250000);

    result.fold(
      (value) => expect(value, same(failure)),
      (_) => fail('Expected Left result'),
    );
  });

  test('OpenCashier memetakan exception tak terduga ke UnknownFailure',
      () async {
    repository.onOpenCashier = (balance) => Future.error(Exception('boom'));

    final result = await OpenCashier(repository)(250000);

    result.fold(
      (value) => expect(value, isA<UnknownFailure>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('GetLatestShift mengembalikan shift terakhir saat sukses', () async {
    final result = await GetLatestShift(repository)();

    result.fold(
      (_) => fail('Expected Right result'),
      (shift) => expect(shift?.openingBalance, equals(120000)),
    );
  });

  test('GetLatestShift memetakan thrown Failure ke Left', () async {
    const failure = NetworkFailure();
    repository.onGetLatestShift = () => Future.error(failure);

    final result = await GetLatestShift(repository)();

    result.fold(
      (value) => expect(value, same(failure)),
      (_) => fail('Expected Left result'),
    );
  });
}
