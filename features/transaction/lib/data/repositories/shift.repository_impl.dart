import 'package:core/core.dart';
import 'package:transaction/data/models/close_cashier_request.model.dart';
import 'package:transaction/data/datasources/shift_remote.data_source.dart';
import 'package:transaction/data/models/open_cashier_request.model.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  ShiftRepositoryImpl({
    required this.remote,
  });

  final ShiftRemoteDataSource remote;
  static final Logger _logger = Logger('ShiftRepositoryImpl');

  @override
  Future<Either<Failure, ShiftStatusEntity>> getShiftStatus() async {
    try {
      final response = await remote.getShiftStatus();

      if (!response.success) {
        return Left(
          ServerValidation(
            response.message.isEmpty
                ? 'Gagal memeriksa status shift'
                : response.message,
          ),
        );
      }

      return Right(
        ShiftStatusEntity(
          isOpen: response.isOpen,
          message: response.message,
          shift: response.shift == null
              ? null
              : ShiftEntity.fromModel(response.shift!),
        ),
      );
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat getShiftStatus', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ShiftEntity?>> getLatestShift() async {
    try {
      final response = await remote.getLatestShift();
      if (response == null) {
        return const Right(null);
      }
      return Right(ShiftEntity.fromModel(response));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat getLatestShift', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> openCashier(
    int initialBalance,
  ) async {
    try {
      final response = await remote.openCashier(
        OpenCashierRequestModel(initialBalance: initialBalance),
      );

      if (!response.success) {
        return Left(
          ServerValidation(
            response.message.isEmpty ? 'Gagal membuka kasir' : response.message,
          ),
        );
      }

      return Right(
        ShiftStatusEntity(
          isOpen: true,
          message: response.message,
          shift: response.shift == null
              ? ShiftEntity(openingBalance: initialBalance, isClosed: false)
              : ShiftEntity.fromModel(response.shift!),
        ),
      );
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat openCashier', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CloseCashierStatusEntity>>
      getCloseCashierStatus() async {
    try {
      final response = await remote.getCloseCashierStatus();

      if (!response.success) {
        return Left(
          ServerValidation(
            response.message.isEmpty
                ? 'Gagal memeriksa status tutup kasir'
                : response.message,
          ),
        );
      }

      return Right(
        CloseCashierStatusEntity(
          canClose: response.canClose,
          message: response.message,
          pendingOrders: response.pendingOrders,
        ),
      );
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat getCloseCashierStatus', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> closeCashier(
    int cashInDrawer,
  ) async {
    try {
      final response = await remote.closeCashier(
        CloseCashierRequestModel(cashInDrawer: cashInDrawer),
      );

      if (!response.success) {
        return Left(
          ServerValidation(
            response.message.isEmpty
                ? 'Gagal menutup kasir'
                : response.message,
          ),
        );
      }

      return Right(
        ShiftStatusEntity(
          isOpen: false,
          message: response.message,
          shift: response.shift == null
              ? ShiftEntity(
                  closingBalance: cashInDrawer,
                  isClosed: true,
                )
              : ShiftEntity.fromModel(response.shift!),
        ),
      );
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat closeCashier', e, st);
      return const Left(UnknownFailure());
    }
  }
}
