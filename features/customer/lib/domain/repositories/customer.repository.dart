import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers(
      {String? query, bool? isOffline});
  Future<Either<Failure, CustomerEntity>> getCustomer(int id,
      {bool? isOffline});
  Future<Either<Failure, CustomerEntity>> createCustomer(
      CustomerEntity customer,
      {bool? isOffline});
  Future<Either<Failure, CustomerEntity>> updateCustomer(
      CustomerEntity customer,
      {bool? isOffline});
  Future<Either<Failure, bool>> deleteCustomer(int id, {bool? isOffline});
}
