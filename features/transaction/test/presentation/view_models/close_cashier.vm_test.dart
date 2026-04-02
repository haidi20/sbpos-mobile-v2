import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';
import 'package:transaction/domain/usecases/close_cashier.usecase.dart';
import 'package:transaction/domain/usecases/get_close_cashier_status.usecase.dart';
import 'package:transaction/presentation/view_models/close_cashier.state.dart';
import 'package:transaction/presentation/view_models/close_cashier.vm.dart';

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
  late CloseCashierViewModel viewModel;

  setUp(() {
    repository = _FakeShiftRepository();
    viewModel = CloseCashierViewModel(
      getCloseCashierStatus: GetCloseCashierStatus(repository),
      closeCashier: CloseCashier(repository),
    );
  });

  test('state awal mengikuti default screen tutup kasir', () {
    expect(viewModel.state, const CloseCashierState());
  });

  test('getCloseCashierStatus mengizinkan submit saat kasir dapat ditutup',
      () async {
    await viewModel.getCloseCashierStatus();

    expect(viewModel.state.hasCheckedStatus, isTrue);
    expect(viewModel.state.canCloseCashier, isTrue);
    expect(viewModel.state.pendingOrders, equals(0));
    expect(viewModel.state.errorMessage, isEmpty);
  });

  test('getCloseCashierStatus menyimpan warning saat masih ada pending order',
      () async {
    repository.onGetCloseCashierStatus = () async => const Right(
          CloseCashierStatusEntity(
            canClose: false,
            message: 'Masih ada pesanan pending',
            pendingOrders: 2,
          ),
        );

    await viewModel.getCloseCashierStatus();

    expect(viewModel.state.canCloseCashier, isFalse);
    expect(viewModel.state.pendingOrders, equals(2));
    expect(viewModel.state.warningMessage, equals('Masih ada pesanan pending'));
  });

  test('setCashInDrawer memformat nominal rupiah dari input digit', () {
    viewModel.setCashInDrawer('350000');

    expect(viewModel.state.cashInDrawerInput, equals('350000'));
    expect(viewModel.state.formattedCashInDrawer, equals('Rp 350.000'));
    expect(viewModel.state.cashInDrawerValue, equals(350000));
  });

  test('onCloseCashier gagal bila status belum dicek', () async {
    viewModel.setCashInDrawer('350000');

    final result = await viewModel.onCloseCashier();

    expect(result, isFalse);
    expect(
      viewModel.state.errorMessage,
      equals('Status tutup kasir belum diperiksa'),
    );
  });

  test('onCloseCashier gagal bila masih ada pending order', () async {
    repository.onGetCloseCashierStatus = () async => const Right(
          CloseCashierStatusEntity(
            canClose: false,
            message: 'Masih ada pesanan pending',
            pendingOrders: 1,
          ),
        );
    await viewModel.getCloseCashierStatus();
    viewModel.setCashInDrawer('350000');

    final result = await viewModel.onCloseCashier();

    expect(result, isFalse);
    expect(
      viewModel.state.errorMessage,
      equals('Masih ada pesanan pending'),
    );
  });

  test('onCloseCashier gagal bila nominal belum diisi', () async {
    await viewModel.getCloseCashierStatus();

    final result = await viewModel.onCloseCashier();

    expect(result, isFalse);
    expect(viewModel.state.errorMessage, equals('Uang Di Kasir wajib diisi'));
  });

  test('onCloseCashier gagal bila nominal nol', () async {
    await viewModel.getCloseCashierStatus();
    viewModel.setCashInDrawer('0');

    final result = await viewModel.onCloseCashier();

    expect(result, isFalse);
    expect(
      viewModel.state.errorMessage,
      equals('Uang Di Kasir harus lebih besar dari nol'),
    );
  });

  test('onCloseCashier sukses memperbarui status dan pesan sukses', () async {
    await viewModel.getCloseCashierStatus();
    viewModel.setCashInDrawer('350000');

    final result = await viewModel.onCloseCashier();

    expect(result, isTrue);
    expect(viewModel.state.isClosed, isTrue);
    expect(viewModel.state.successMessage, equals('Tutup kasir berhasil'));
    expect(
      viewModel.state.shiftStatus?.shift?.closingBalance,
      equals(350000),
    );
  });

  test('onCloseCashier menampilkan pesan error dari failure', () async {
    repository.onCloseCashier =
        (cashInDrawer) async => const Left(NetworkFailure());
    await viewModel.getCloseCashierStatus();
    viewModel.setCashInDrawer('350000');

    final result = await viewModel.onCloseCashier();

    expect(result, isFalse);
    expect(viewModel.state.errorMessage, equals('Tidak ada koneksi internet.'));
  });
}
