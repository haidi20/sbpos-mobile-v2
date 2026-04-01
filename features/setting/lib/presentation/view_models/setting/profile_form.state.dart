import 'package:core/core.dart';

@immutable
class ProfileFormState {
  final String name;
  final String employeeId;
  final String email;
  final String phone;
  final String errorMessage;
  final String successMessage;

  const ProfileFormState({
    required this.name,
    required this.employeeId,
    required this.email,
    required this.phone,
    required this.errorMessage,
    required this.successMessage,
  });

  const ProfileFormState.initial()
      : name = 'Budi Santoso',
        employeeId = 'EMP-2023-001',
        email = 'budi@sbpos.com',
        phone = '0812-9999-8888',
        errorMessage = '',
        successMessage = '';

  ProfileFormState copyWith({
    String? name,
    String? employeeId,
    String? email,
    String? phone,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileFormState(
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
