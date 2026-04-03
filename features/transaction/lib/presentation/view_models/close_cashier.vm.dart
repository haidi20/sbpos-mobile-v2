import 'package:core/core.dart';
import 'package:transaction/domain/usecases/close_cashier.usecase.dart';
import 'package:transaction/domain/usecases/get_close_cashier_status.usecase.dart';
import 'package:transaction/presentation/view_models/close_cashier.state.dart';

class CloseCashierViewModel extends StateNotifier<CloseCashierState> {
  CloseCashierViewModel({
    required GetCloseCashierStatus getCloseCashierStatus,
    required CloseCashier closeCashier,
  })  : _getCloseCashierStatus = getCloseCashierStatus,
        _closeCashier = closeCashier,
        super(const CloseCashierState());

  final GetCloseCashierStatus _getCloseCashierStatus;
  final CloseCashier _closeCashier;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> getCloseCashierStatus() async {
    if (state.isLoadingStatus) {
      return;
    }

    state = state.copyWith(
      isLoadingStatus: true,
      errorMessage: '',
      successMessage: '',
      warningMessage: '',
    );

    final result = await _getCloseCashierStatus();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingStatus: false,
          hasCheckedStatus: true,
          canCloseCashier: false,
          errorMessage: failure.message,
          successMessage: '',
          warningMessage: '',
        );
      },
      (status) {
        state = state.copyWith(
          isLoadingStatus: false,
          hasCheckedStatus: true,
          canCloseCashier: status.canClose,
          pendingOrders: status.pendingOrders,
          warningMessage: status.canClose ? '' : status.message,
          errorMessage: '',
          successMessage: '',
        );
      },
    );
  }

  void setCashInDrawer(String rawInput) {
    final digits = rawInput.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(digits) ?? 0;

    state = state.copyWith(
      cashInDrawerInput: digits,
      cashInDrawerValue: value,
      formattedCashInDrawer: _currencyFormat.format(value),
      errorMessage: '',
      successMessage: '',
    );
  }

  Future<bool> onCloseCashier() async {
    if (!state.hasCheckedStatus) {
      state = state.copyWith(
        errorMessage: 'Status tutup kasir belum diperiksa',
        successMessage: '',
      );
      return false;
    }

    if (!state.canCloseCashier) {
      state = state.copyWith(
        errorMessage: state.warningMessage.isEmpty
            ? 'Kasir belum dapat ditutup'
            : state.warningMessage,
        successMessage: '',
      );
      return false;
    }

    if (state.cashInDrawerInput.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Uang Di Kasir wajib diisi',
        successMessage: '',
      );
      return false;
    }

    if (state.cashInDrawerValue <= 0) {
      state = state.copyWith(
        errorMessage: 'Uang Di Kasir harus lebih besar dari nol',
        successMessage: '',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: '',
      successMessage: '',
    );

    final result = await _closeCashier(state.cashInDrawerValue);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          successMessage: '',
        );
        return false;
      },
      (status) {
        state = state.copyWith(
          isSubmitting: false,
          isClosed: true,
          canCloseCashier: false,
          shiftStatus: status,
          errorMessage: '',
          successMessage: status.message,
        );
        return true;
      },
    );
  }
}
