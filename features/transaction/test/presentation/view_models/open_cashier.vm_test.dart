import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';
import 'package:transaction/domain/usecases/get_latest_shift.usecase.dart';
import 'package:transaction/domain/usecases/get_shift_status.usecase.dart';
import 'package:transaction/domain/usecases/open_cashier.usecase.dart';
import 'package:transaction/presentation/view_models/open_cashier.state.dart';
import 'package:transaction/presentation/view_models/open_cashier.vm.dart';

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
            openingBalance: 140000,
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
  late OpenCashierViewModel viewModel;

  setUp(() {
    repository = _FakeShiftRepository();
    viewModel = OpenCashierViewModel(
      getShiftStatus: GetShiftStatus(repository),
      getLatestShift: GetLatestShift(repository),
      openCashier: OpenCashier(repository),
    );
  });

  test('state awal mengikuti default screen buka kasir', () {
    expect(viewModel.state, const OpenCashierState());
  });

  test('getShiftStatus memaksa buka kasir saat status belum terbuka', () async {
    await viewModel.getShiftStatus();

    expect(viewModel.state.hasCheckedStatus, isTrue);
    expect(viewModel.state.shouldForceOpenCashier, isTrue);
    expect(viewModel.state.isShiftOpen, isFalse);
    expect(viewModel.state.errorMessage, isEmpty);
  });

  test(
      'getShiftStatus memprefill saldo dari buka kasir sebelumnya saat tersedia',
      () async {
    repository.onGetShiftStatus = () async => const Right(
          ShiftStatusEntity(
            isOpen: false,
            message: 'Shift belum dibuka',
            shift: ShiftEntity(
              idServer: 5,
              shiftNumber: 1,
              openingBalance: 175000,
              isClosed: true,
            ),
          ),
        );

    await viewModel.getShiftStatus();

    expect(viewModel.state.shouldForceOpenCashier, isTrue);
    expect(viewModel.state.balanceInput, equals('175000'));
    expect(viewModel.state.balanceValue, equals(175000));
    expect(viewModel.state.formattedBalance, equals('Rp 175.000'));
  });

  test('getShiftStatus memakai shift/latest saat status shift belum punya saldo',
      () async {
    repository.onGetShiftStatus = () async => const Right(
          ShiftStatusEntity(
            isOpen: false,
            message: 'Shift belum dibuka',
          ),
        );
    repository.onGetLatestShift = () async => Right(
          ShiftEntity(
            openingBalance: 210000,
            shiftNumber: 4,
          ),
        );

    await viewModel.getShiftStatus();

    expect(viewModel.state.balanceInput, equals('210000'));
    expect(viewModel.state.balanceValue, equals(210000));
    expect(viewModel.state.formattedBalance, equals('Rp 210.000'));
  });

  test('getShiftStatus membuka akses saat server menyatakan shift sudah dibuka',
      () async {
    repository.onGetShiftStatus = () async => const Right(
          ShiftStatusEntity(
            isOpen: true,
            message: 'Shift sudah dibuka',
          ),
        );

    await viewModel.getShiftStatus();

    expect(viewModel.state.shouldForceOpenCashier, isFalse);
    expect(viewModel.state.isShiftOpen, isTrue);
    expect(viewModel.state.successMessage, equals('Shift sudah dibuka'));
  });

  test('getShiftStatus menandai saran tutup kasir saat shift beda hari',
      () async {
    repository.onGetShiftStatus = () async => Right(
          ShiftStatusEntity(
            isOpen: true,
            message: 'Shift lama masih aktif',
            shift: ShiftEntity(
              idServer: 7,
              shiftNumber: 1,
              date: DateTime.now().subtract(const Duration(days: 1)),
              isClosed: false,
            ),
          ),
        );

    await viewModel.getShiftStatus();

    expect(viewModel.state.isShiftOpen, isTrue);
    expect(viewModel.state.shouldSuggestCloseCashier, isTrue);
    expect(viewModel.state.staleShiftPromptKey, isNotEmpty);
  });

  test('dismissCloseCashierSuggestion menyembunyikan prompt shift lama',
      () async {
    repository.onGetShiftStatus = () async => Right(
          ShiftStatusEntity(
            isOpen: true,
            message: 'Shift lama masih aktif',
            shift: ShiftEntity(
              idServer: 8,
              shiftNumber: 2,
              date: DateTime.now().subtract(const Duration(days: 1)),
              isClosed: false,
            ),
          ),
        );

    await viewModel.getShiftStatus();
    viewModel.dismissCloseCashierSuggestion();

    expect(viewModel.state.shouldSuggestCloseCashier, isFalse);
    expect(viewModel.state.dismissedShiftPromptKey, isNotEmpty);

    await viewModel.getShiftStatus();

    expect(viewModel.state.shouldSuggestCloseCashier, isFalse);
  });

  test('setInitialBalance memformat nominal rupiah dari input digit', () {
    viewModel.setInitialBalance('250000');

    expect(viewModel.state.balanceInput, equals('250000'));
    expect(viewModel.state.formattedBalance, equals('Rp 250.000'));
    expect(viewModel.state.balanceValue, equals(250000));
  });

  test('onOpenCashier gagal bila saldo belum diisi', () async {
    final result = await viewModel.onOpenCashier();

    expect(result, isFalse);
    expect(
      viewModel.state.errorMessage,
      equals('Saldo Kasir wajib diisi'),
    );
  });

  test('onOpenCashier gagal bila saldo nol', () async {
    viewModel.setInitialBalance('0');

    final result = await viewModel.onOpenCashier();

    expect(result, isFalse);
    expect(
      viewModel.state.errorMessage,
      equals('Saldo Kasir harus lebih besar dari nol'),
    );
  });

  test('onOpenCashier sukses memperbarui status dan pesan sukses', () async {
    viewModel.setInitialBalance('250000');

    final result = await viewModel.onOpenCashier();

    expect(result, isTrue);
    expect(viewModel.state.isShiftOpen, isTrue);
    expect(viewModel.state.shouldForceOpenCashier, isFalse);
    expect(viewModel.state.successMessage, equals('Buka kasir berhasil'));
    expect(viewModel.state.shiftStatus?.shift?.openingBalance, equals(250000));
  });

  test('onOpenCashier menampilkan pesan error dari failure', () async {
    repository.onOpenCashier =
        (balance) async => const Left(NetworkFailure());
    viewModel.setInitialBalance('250000');

    final result = await viewModel.onOpenCashier();

    expect(result, isFalse);
    expect(viewModel.state.errorMessage, equals('Tidak ada koneksi internet.'));
  });
}
