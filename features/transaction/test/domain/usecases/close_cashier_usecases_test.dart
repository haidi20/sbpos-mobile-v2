import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';
import 'package:transaction/domain/usecases/close_cashier.usecase.dart';
import 'package:transaction/domain/usecases/get_close_cashier_status.usecase.dart';

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
      return Future.value(const Right(null));
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

  test('GetCloseCashierStatus mengembalikan entity saat sukses', () async {
    final result = await GetCloseCashierStatus(repository)();

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) {
        expect(entity.canClose, isTrue);
        expect(entity.pendingOrders, equals(0));
      },
    );
  });

  test('GetCloseCashierStatus memetakan thrown Failure ke Left', () async {
    const failure = NetworkFailure();
    repository.onGetCloseCashierStatus = () => Future.error(failure);

    final result = await GetCloseCashierStatus(repository)();

    result.fold(
      (value) => expect(value, same(failure)),
      (_) => fail('Expected Left result'),
    );
  });

  test(
      'GetCloseCashierStatus memetakan exception tak terduga ke UnknownFailure',
      () async {
    repository.onGetCloseCashierStatus = () => Future.error(Exception('boom'));

    final result = await GetCloseCashierStatus(repository)();

    result.fold(
      (value) => expect(value, isA<UnknownFailure>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('CloseCashier mengembalikan entity saat sukses', () async {
    final result = await CloseCashier(repository)(500000);

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) {
        expect(entity.isOpen, isFalse);
        expect(entity.shift?.closingBalance, equals(500000));
        expect(entity.shift?.isClosed, isTrue);
      },
    );
  });

  test('CloseCashier memetakan thrown Failure ke Left', () async {
    const failure = ServerFailure();
    repository.onCloseCashier = (cashInDrawer) => Future.error(failure);

    final result = await CloseCashier(repository)(500000);

    result.fold(
      (value) => expect(value, same(failure)),
      (_) => fail('Expected Left result'),
    );
  });

  test('CloseCashier memetakan exception tak terduga ke UnknownFailure',
      () async {
    repository.onCloseCashier =
        (cashInDrawer) => Future.error(Exception('boom'));

    final result = await CloseCashier(repository)(500000);

    result.fold(
      (value) => expect(value, isA<UnknownFailure>()),
      (_) => fail('Expected Left result'),
    );
  });
}
