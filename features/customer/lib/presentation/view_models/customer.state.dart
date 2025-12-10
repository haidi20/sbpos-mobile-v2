import 'package:customer/domain/entities/customer.entity.dart';

class CustomerState {
  final bool loading;
  final List<CustomerEntity> customers;
  final CustomerEntity? selectedCustomer;
  final String? error;
  final bool isAdding;
  final String? searchQuery;

  const CustomerState({
    this.loading = false,
    this.customers = const [],
    this.selectedCustomer,
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

  factory CustomerState.cleared() {
    return const CustomerState(
      loading: false,
      customers: [],
      selectedCustomer: null,
      error: null,
      isAdding: false,
      searchQuery: null,
    );
  }
}

// tambahkan code di bawah ini
extension CustomerStateClearX on CustomerState {
  CustomerState clear({
    bool clearError = false,
    bool clearCustomers = false,
    bool clearSelectedCustomer = false,
    bool clearSearchQuery = false,
    bool resetLoading = false,
    bool resetIsAdding = false,
  }) {
    return CustomerState(
      loading: resetLoading ? false : loading,
      customers: clearCustomers ? const [] : customers,
      selectedCustomer: clearSelectedCustomer ? null : selectedCustomer,
      error: clearError ? null : error,
      isAdding: resetIsAdding ? false : isAdding,
      searchQuery: clearSearchQuery ? null : searchQuery,
    );
  }
}
