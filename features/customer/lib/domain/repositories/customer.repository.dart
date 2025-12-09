import 'package:customer/domain/entities/customer.entity.dart';

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getCustomers();
  Future<void> saveCustomer(CustomerEntity customer);
}
