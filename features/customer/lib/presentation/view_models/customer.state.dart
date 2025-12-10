import 'package:customer/domain/entities/customer.entity.dart';

class CustomerState {
  final bool loading;
  final List<CustomerEntity> customers;
  final String? error;
  final bool isAdding;
  final String searchQuery;
  const CustomerState({
    this.loading = false,
    this.customers = const [],
    this.error,
    this.isAdding = false,
    this.searchQuery = '',
  });

  CustomerState copyWith({
    bool? loading,
    String? error,
    List<CustomerEntity>? customers,
    bool? isAdding,
    String? searchQuery,
  }) =>
      CustomerState(
        loading: loading ?? this.loading,
        customers: customers ?? this.customers,
        error: error ?? this.error,
        isAdding: isAdding ?? this.isAdding,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}
