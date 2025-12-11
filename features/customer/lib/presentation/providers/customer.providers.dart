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
final getCustomersProvider = Provider((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return GetCustomers(repo!);
});

final customerViewModelProvider =
    StateNotifierProvider<CustomerViewModel, CustomerState>((ref) {
  final del = ref.read(deleteCustomer);
  final create = ref.read(createCustomer);
  final update = ref.read(updateCustomer);
  final getCustomers = ref.read(getCustomersProvider);
  return CustomerViewModel(
    deleteCustomerUsecase: del,
    createCustomerUsecase: create,
    updateCustomerUsecase: update,
    getCustomersUsecase: getCustomers,
  );
});
