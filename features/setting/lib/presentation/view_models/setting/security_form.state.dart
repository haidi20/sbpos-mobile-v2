import 'package:core/core.dart';

@immutable
class SecurityFormState {
  final String oldPin;
  final String newPin;
  final String confirmPin;
  final String errorMessage;
  final String successMessage;

  const SecurityFormState({
    required this.oldPin,
    required this.newPin,
    required this.confirmPin,
    required this.errorMessage,
    required this.successMessage,
  });

  const SecurityFormState.initial()
      : oldPin = '',
        newPin = '',
        confirmPin = '',
        errorMessage = '',
        successMessage = '';

  SecurityFormState copyWith({
    String? oldPin,
    String? newPin,
    String? confirmPin,
    String? errorMessage,
    String? successMessage,
  }) {
    return SecurityFormState(
      oldPin: oldPin ?? this.oldPin,
      newPin: newPin ?? this.newPin,
      confirmPin: confirmPin ?? this.confirmPin,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
