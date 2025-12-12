import 'package:customer/domain/entities/customer.entity.dart';

class CustomerState {
  final bool loading;
  final List<CustomerEntity> customers;
  final CustomerEntity? selectedCustomer;
  final String? error;
  final bool isForm;
  final String? searchQuery;

  const CustomerState({
    this.loading = false,
    this.customers = const [],
    this.selectedCustomer,
    this.error,
    this.isForm = false,
    this.searchQuery = '',
  });

  CustomerState copyWith({
    bool? loading,
    String? error,
    List<CustomerEntity>? customers,
    bool? isForm,
    String? searchQuery,
  }) =>
      CustomerState(
        loading: loading ?? this.loading,
        customers: customers ?? this.customers,
        error: error ?? this.error,
        isForm: isForm ?? this.isForm,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  factory CustomerState.cleared() {
    return const CustomerState(
      loading: false,
      customers: [],
      selectedCustomer: null,
      error: null,
      isForm: false,
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
    bool resetIsForm = false,
  }) {
    return CustomerState(
      loading: resetLoading ? false : loading,
      customers: clearCustomers ? const [] : customers,
      selectedCustomer: clearSelectedCustomer ? null : selectedCustomer,
      error: clearError ? null : error,
      isForm: resetIsForm ? false : isForm,
      searchQuery: clearSearchQuery ? null : searchQuery,
    );
  }
}
