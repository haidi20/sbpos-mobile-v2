import 'package:core/core.dart';

@immutable
class StoreInfoState {
  final String storeName;
  final String branch;
  final String address;
  final String phone;
  final String errorMessage;
  final String successMessage;

  const StoreInfoState({
    required this.storeName,
    required this.branch,
    required this.address,
    required this.phone,
    required this.errorMessage,
    required this.successMessage,
  });

  const StoreInfoState.initial()
      : storeName = 'SB Coffee',
        branch = 'Jakarta Selatan',
        address = 'Jl. Sudirman No. 45, SCBD, Jakarta Selatan',
        phone = '0812-3456-7890',
        errorMessage = '',
        successMessage = '';

  StoreInfoState copyWith({
    String? storeName,
    String? branch,
    String? address,
    String? phone,
    String? errorMessage,
    String? successMessage,
  }) {
    return StoreInfoState(
      storeName: storeName ?? this.storeName,
      branch: branch ?? this.branch,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
