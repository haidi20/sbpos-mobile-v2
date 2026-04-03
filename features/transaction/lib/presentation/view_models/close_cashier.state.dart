import 'package:transaction/domain/entitties/shift_status.entity.dart';

class CloseCashierState {
  final bool isLoadingStatus;
  final bool isSubmitting;
  final bool hasCheckedStatus;
  final bool canCloseCashier;
  final bool isClosed;
  final int pendingOrders;
  final String cashInDrawerInput;
  final int cashInDrawerValue;
  final String formattedCashInDrawer;
  final String warningMessage;
  final String errorMessage;
  final String successMessage;
  final ShiftStatusEntity? shiftStatus;

  const CloseCashierState({
    this.isLoadingStatus = false,
    this.isSubmitting = false,
    this.hasCheckedStatus = false,
    this.canCloseCashier = false,
    this.isClosed = false,
    this.pendingOrders = 0,
    this.cashInDrawerInput = '',
    this.cashInDrawerValue = 0,
    this.formattedCashInDrawer = 'Rp 0',
    this.warningMessage = '',
    this.errorMessage = '',
    this.successMessage = '',
    this.shiftStatus,
  });

  CloseCashierState copyWith({
    bool? isLoadingStatus,
    bool? isSubmitting,
    bool? hasCheckedStatus,
    bool? canCloseCashier,
    bool? isClosed,
    int? pendingOrders,
    String? cashInDrawerInput,
    int? cashInDrawerValue,
    String? formattedCashInDrawer,
    String? warningMessage,
    String? errorMessage,
    String? successMessage,
    ShiftStatusEntity? shiftStatus,
  }) {
    return CloseCashierState(
      isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasCheckedStatus: hasCheckedStatus ?? this.hasCheckedStatus,
      canCloseCashier: canCloseCashier ?? this.canCloseCashier,
      isClosed: isClosed ?? this.isClosed,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      cashInDrawerInput: cashInDrawerInput ?? this.cashInDrawerInput,
      cashInDrawerValue: cashInDrawerValue ?? this.cashInDrawerValue,
      formattedCashInDrawer:
          formattedCashInDrawer ?? this.formattedCashInDrawer,
      warningMessage: warningMessage ?? this.warningMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      shiftStatus: shiftStatus ?? this.shiftStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CloseCashierState &&
        other.isLoadingStatus == isLoadingStatus &&
        other.isSubmitting == isSubmitting &&
        other.hasCheckedStatus == hasCheckedStatus &&
        other.canCloseCashier == canCloseCashier &&
        other.isClosed == isClosed &&
        other.pendingOrders == pendingOrders &&
        other.cashInDrawerInput == cashInDrawerInput &&
        other.cashInDrawerValue == cashInDrawerValue &&
        other.formattedCashInDrawer == formattedCashInDrawer &&
        other.warningMessage == warningMessage &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        other.shiftStatus == shiftStatus;
  }

  @override
  int get hashCode => Object.hash(
        isLoadingStatus,
        isSubmitting,
        hasCheckedStatus,
        canCloseCashier,
        isClosed,
        pendingOrders,
        cashInDrawerInput,
        cashInDrawerValue,
        formattedCashInDrawer,
        warningMessage,
        errorMessage,
        successMessage,
        shiftStatus,
      );
}
