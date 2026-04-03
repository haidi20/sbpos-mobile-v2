import 'package:core/core.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/usecases/get_latest_shift.usecase.dart';
import 'package:transaction/domain/usecases/get_shift_status.usecase.dart';
import 'package:transaction/domain/usecases/open_cashier.usecase.dart';
import 'package:transaction/presentation/view_models/open_cashier.state.dart';

class OpenCashierViewModel extends StateNotifier<OpenCashierState> {
  OpenCashierViewModel({
    required GetShiftStatus getShiftStatus,
    GetLatestShift? getLatestShift,
    required OpenCashier openCashier,
  })  : _getShiftStatus = getShiftStatus,
        _getLatestShift = getLatestShift,
        _openCashier = openCashier,
        super(const OpenCashierState());

  final GetShiftStatus _getShiftStatus;
  final GetLatestShift? _getLatestShift;
  final OpenCashier _openCashier;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _applySuggestedOpeningBalance(int suggestedBalance) {
    if (suggestedBalance <= 0) {
      return;
    }

    final digits = suggestedBalance.toString();
    state = state.copyWith(
      balanceInput: digits,
      balanceValue: suggestedBalance,
      formattedBalance: _currencyFormat.format(suggestedBalance),
    );
  }

  bool _isShiftFromPreviousDay(ShiftStatusEntity status) {
    final shift = status.shift;
    final shiftDate = shift?.date ?? shift?.startTime ?? shift?.createdAt;
    if (shiftDate == null) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final shiftDay = DateTime(shiftDate.year, shiftDate.month, shiftDate.day);

    return shiftDay.isBefore(today);
  }

  String _buildShiftPromptKey(ShiftEntity? shift) {
    if (shift == null) {
      return '';
    }

    final primaryId = shift.idServer ?? shift.id;
    if (primaryId != null) {
      return 'shift:$primaryId';
    }

    final shiftDay = shift.date ?? shift.startTime ?? shift.createdAt;
    final normalizedDay = shiftDay == null
        ? ''
        : '${shiftDay.year.toString().padLeft(4, '0')}-'
            '${shiftDay.month.toString().padLeft(2, '0')}-'
            '${shiftDay.day.toString().padLeft(2, '0')}';

    return [
      shift.shiftNumber?.toString() ?? '',
      normalizedDay,
    ].join('|');
  }

  Future<void> getShiftStatus() async {
    if (state.isLoadingStatus) {
      return;
    }

    state = state.copyWith(
      isLoadingStatus: true,
      errorMessage: '',
      successMessage: '',
    );

    final result = await _getShiftStatus();
    await result.fold<Future<void>>(
      (failure) async {
        state = state.copyWith(
          isLoadingStatus: false,
          hasCheckedStatus: true,
          errorMessage: failure.message,
          successMessage: '',
        );
      },
      (status) async {
        final isDifferentDayShift =
            status.isOpen && _isShiftFromPreviousDay(status);
        final staleShiftPromptKey =
            isDifferentDayShift ? _buildShiftPromptKey(status.shift) : '';
        final alreadyDismissed = isDifferentDayShift &&
            staleShiftPromptKey.isNotEmpty &&
            staleShiftPromptKey == state.dismissedShiftPromptKey;
        var suggestedOpeningBalance =
            status.shift?.openingBalance ?? state.balanceValue;
        final getLatestShift = _getLatestShift;

        if (!status.isOpen &&
            (suggestedOpeningBalance <= 0) &&
            getLatestShift != null) {
          final latestShiftResult = await getLatestShift();
          latestShiftResult.fold(
            (_) {},
            (latestShift) {
              suggestedOpeningBalance =
                  latestShift?.openingBalance ?? suggestedOpeningBalance;
            },
          );
        }

        state = state.copyWith(
          isLoadingStatus: false,
          hasCheckedStatus: true,
          shouldForceOpenCashier: !status.isOpen,
          shouldSuggestCloseCashier:
              isDifferentDayShift && !alreadyDismissed,
          isShiftOpen: status.isOpen,
          staleShiftPromptKey: staleShiftPromptKey,
          dismissedShiftPromptKey:
              isDifferentDayShift ? state.dismissedShiftPromptKey : '',
          shiftStatus: status,
          errorMessage: '',
          successMessage: status.isOpen ? status.message : '',
        );

        if (!status.isOpen) {
          _applySuggestedOpeningBalance(suggestedOpeningBalance);
        }
      },
    );
  }

  void setInitialBalance(String rawInput) {
    final digits = rawInput.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(digits) ?? 0;

    state = state.copyWith(
      balanceInput: digits,
      balanceValue: value,
      formattedBalance: _currencyFormat.format(value),
      errorMessage: '',
      successMessage: '',
    );
  }

  void dismissCloseCashierSuggestion() {
    state = state.copyWith(
      shouldSuggestCloseCashier: false,
      dismissedShiftPromptKey: state.staleShiftPromptKey.isEmpty
          ? state.dismissedShiftPromptKey
          : state.staleShiftPromptKey,
    );
  }

  Future<bool> onOpenCashier() async {
    if (state.balanceInput.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Saldo Kasir wajib diisi',
        successMessage: '',
      );
      return false;
    }

    if (state.balanceValue <= 0) {
      state = state.copyWith(
        errorMessage: 'Saldo Kasir harus lebih besar dari nol',
        successMessage: '',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: '',
      successMessage: '',
    );

    final result = await _openCashier(state.balanceValue);

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
          hasCheckedStatus: true,
          shouldForceOpenCashier: false,
          shouldSuggestCloseCashier: false,
          isShiftOpen: true,
          staleShiftPromptKey: '',
          dismissedShiftPromptKey: '',
          shiftStatus: status,
          errorMessage: '',
          successMessage: status.message,
        );
        return true;
      },
    );
  }
}
