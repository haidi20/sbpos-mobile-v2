import 'package:core/core.dart';
import 'package:transaction/domain/usecases/get_latest_shift.usecase.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';
import 'package:transaction/domain/usecases/get_shift_status.usecase.dart';
import 'package:transaction/domain/usecases/open_cashier.usecase.dart';
import 'package:transaction/presentation/view_models/open_cashier.state.dart';
import 'package:transaction/presentation/view_models/open_cashier.vm.dart';

final shiftRepositoryProvider = Provider<ShiftRepository?>(
  (ref) => throw UnimplementedError(
    'shiftRepositoryProvider must be overridden in the app composition root.',
  ),
);

final getShiftStatusProvider = Provider(
  (ref) => GetShiftStatus(ref.watch(shiftRepositoryProvider)!),
);

final getLatestShiftProvider = Provider(
  (ref) => GetLatestShift(ref.watch(shiftRepositoryProvider)!),
);

final openCashierProvider = Provider(
  (ref) => OpenCashier(ref.watch(shiftRepositoryProvider)!),
);

final openCashierViewModelProvider =
    StateNotifierProvider<OpenCashierViewModel, OpenCashierState>(
  (ref) => OpenCashierViewModel(
    getShiftStatus: ref.watch(getShiftStatusProvider),
    getLatestShift: ref.watch(getLatestShiftProvider),
    openCashier: ref.watch(openCashierProvider),
  ),
);
