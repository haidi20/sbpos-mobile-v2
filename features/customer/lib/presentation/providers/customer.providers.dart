import 'package:core/core.dart';
import 'package:customer/presentation/view_models/customer.vm.dart';
import 'package:customer/domain/usecases/get_customer.usecase.dart';
import 'package:customer/domain/usecases/get_customers.usecase.dart';
import 'package:customer/presentation/view_models/customer.state.dart';
import 'package:customer/domain/repositories/customer.repository.dart';
import 'package:customer/domain/usecases/create_customer.usecase.dart';
import 'package:customer/domain/usecases/update_customer.usecase.dart';
import 'package:customer/domain/usecases/delete_customer.usecase.dart';
import 'package:customer/data/repositories/customer.repository.impl.dart';
import 'package:customer/data/datasources/local_customer.datasource.dart';
import 'package:customer/data/datasources/remote_customer.datasource.dart';

// Data source & repository providers (mirror transaction provider style)
final customerLocalDataSourceProvider = Provider<LocalCustomerDataSource>(
  (ref) => LocalCustomerDataSource(),
);

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>(
  (ref) => CustomerRemoteDataSource(),
);

final customerRepositoryProvider = Provider<CustomerRepository?>(
  (ref) => CustomerRepositoryImpl(
    local: ref.read(customerLocalDataSourceProvider),
    remote: ref.read(customerRemoteDataSourceProvider),
  ),
);

// Usecase providers
final createCustomer = Provider((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CreateCustomer(repo!);
});

final updateCustomer = Provider((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return UpdateCustomer(repo!);
});

final deleteCustomer = Provider((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return DeleteCustomer(repo!);
});

final getCustomer = Provider((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return GetCustomer(repo!);
});

final getCustomers = Provider((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return GetCustomers(repo!);
});

// ViewModel provider
final customerViewModelProvider =
    StateNotifierProvider<CustomerViewModel, CustomerState>((ref) {
  // Currently CustomerViewModel has a parameterless constructor
  // If later it accepts usecases, wire them here similar to transaction VM.
  return CustomerViewModel();
});
