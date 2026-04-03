import 'package:transaction/domain/entitties/shift_status.entity.dart';

class OpenCashierState {
  final bool isLoadingStatus;
  final bool isSubmitting;
  final bool hasCheckedStatus;
  final bool shouldForceOpenCashier;
  final bool shouldSuggestCloseCashier;
  final bool isShiftOpen;
  final String balanceInput;
  final int balanceValue;
  final String formattedBalance;
  final String errorMessage;
  final String successMessage;
  final String staleShiftPromptKey;
  final String dismissedShiftPromptKey;
  final ShiftStatusEntity? shiftStatus;

  const OpenCashierState({
    this.isLoadingStatus = false,
    this.isSubmitting = false,
    this.hasCheckedStatus = false,
    this.shouldForceOpenCashier = false,
    this.shouldSuggestCloseCashier = false,
    this.isShiftOpen = false,
    this.balanceInput = '',
    this.balanceValue = 0,
    this.formattedBalance = 'Rp 0',
    this.errorMessage = '',
    this.successMessage = '',
    this.staleShiftPromptKey = '',
    this.dismissedShiftPromptKey = '',
    this.shiftStatus,
  });

  OpenCashierState copyWith({
    bool? isLoadingStatus,
    bool? isSubmitting,
    bool? hasCheckedStatus,
    bool? shouldForceOpenCashier,
    bool? shouldSuggestCloseCashier,
    bool? isShiftOpen,
    String? balanceInput,
    int? balanceValue,
    String? formattedBalance,
    String? errorMessage,
    String? successMessage,
    String? staleShiftPromptKey,
    String? dismissedShiftPromptKey,
    ShiftStatusEntity? shiftStatus,
  }) {
    return OpenCashierState(
      isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasCheckedStatus: hasCheckedStatus ?? this.hasCheckedStatus,
      shouldForceOpenCashier:
          shouldForceOpenCashier ?? this.shouldForceOpenCashier,
      shouldSuggestCloseCashier:
          shouldSuggestCloseCashier ?? this.shouldSuggestCloseCashier,
      isShiftOpen: isShiftOpen ?? this.isShiftOpen,
      balanceInput: balanceInput ?? this.balanceInput,
      balanceValue: balanceValue ?? this.balanceValue,
      formattedBalance: formattedBalance ?? this.formattedBalance,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      staleShiftPromptKey: staleShiftPromptKey ?? this.staleShiftPromptKey,
      dismissedShiftPromptKey:
          dismissedShiftPromptKey ?? this.dismissedShiftPromptKey,
      shiftStatus: shiftStatus ?? this.shiftStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenCashierState &&
        other.isLoadingStatus == isLoadingStatus &&
        other.isSubmitting == isSubmitting &&
        other.hasCheckedStatus == hasCheckedStatus &&
        other.shouldForceOpenCashier == shouldForceOpenCashier &&
        other.shouldSuggestCloseCashier == shouldSuggestCloseCashier &&
        other.isShiftOpen == isShiftOpen &&
        other.balanceInput == balanceInput &&
        other.balanceValue == balanceValue &&
        other.formattedBalance == formattedBalance &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        other.staleShiftPromptKey == staleShiftPromptKey &&
        other.dismissedShiftPromptKey == dismissedShiftPromptKey &&
        other.shiftStatus == shiftStatus;
  }

  @override
  int get hashCode => Object.hash(
        isLoadingStatus,
        isSubmitting,
        hasCheckedStatus,
        shouldForceOpenCashier,
        shouldSuggestCloseCashier,
        isShiftOpen,
        balanceInput,
        balanceValue,
        formattedBalance,
        errorMessage,
        successMessage,
        staleShiftPromptKey,
        dismissedShiftPromptKey,
        shiftStatus,
      );
}
