export 'package:transaction/presentation/providers/open_cashier.provider.dart'
    show shiftRepositoryProvider;

import 'package:core/core.dart';
import 'package:transaction/domain/usecases/close_cashier.usecase.dart';
import 'package:transaction/domain/usecases/get_close_cashier_status.usecase.dart';
import 'package:transaction/presentation/providers/open_cashier.provider.dart'
    show shiftRepositoryProvider;
import 'package:transaction/presentation/view_models/close_cashier.state.dart';
import 'package:transaction/presentation/view_models/close_cashier.vm.dart';

final getCloseCashierStatusProvider = Provider(
  (ref) => GetCloseCashierStatus(ref.watch(shiftRepositoryProvider)!),
);

final closeCashierProvider = Provider(
  (ref) => CloseCashier(ref.watch(shiftRepositoryProvider)!),
);

final closeCashierViewModelProvider =
    StateNotifierProvider<CloseCashierViewModel, CloseCashierState>(
  (ref) => CloseCashierViewModel(
    getCloseCashierStatus: ref.watch(getCloseCashierStatusProvider),
    closeCashier: ref.watch(closeCashierProvider),
  ),
);
