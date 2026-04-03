import 'package:core/core.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';

abstract class ShiftRepository {
  Future<Either<Failure, ShiftStatusEntity>> getShiftStatus();

  Future<Either<Failure, ShiftEntity?>> getLatestShift();

  Future<Either<Failure, ShiftStatusEntity>> openCashier(int initialBalance);

  Future<Either<Failure, CloseCashierStatusEntity>> getCloseCashierStatus();

  Future<Either<Failure, ShiftStatusEntity>> closeCashier(int cashInDrawer);
}
