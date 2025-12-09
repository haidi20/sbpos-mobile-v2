import 'package:customer/domain/entities/customer.entity.dart';

class CustomerState {
  final bool loading;
  final List<CustomerEntity> customers;
  final String? error;
  const CustomerState(
      {this.loading = false, this.customers = const [], this.error});

  CustomerState copyWith({
    bool? loading,
    String? error,
    List<CustomerEntity>? customers,
  }) =>
      CustomerState(
        loading: loading ?? this.loading,
        customers: customers ?? this.customers,
        error: error ?? this.error,
      );
}
