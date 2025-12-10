import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers();
  Future<Either<Failure, CustomerEntity>> getCustomer(int id);
  Future<Either<Failure, CustomerEntity>> createCustomer(
      CustomerEntity customer);
  Future<Either<Failure, CustomerEntity>> updateCustomer(
      CustomerEntity customer);
  Future<Either<Failure, bool>> deleteCustomer(int id);
}
