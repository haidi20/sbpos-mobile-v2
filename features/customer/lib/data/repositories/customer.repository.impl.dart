import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';
import 'package:customer/data/datasources/local_customer.datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final LocalCustomerDataSource local;
  CustomerRepositoryImpl(this.local);

  @override
  Future<List<CustomerEntity>> getCustomers() async {
    final models = await local.fetchCustomers();
    return models.map((m) => CustomerEntity.fromModel(m)).toList();
  }

  @override
  Future<void> saveCustomer(CustomerEntity customer) async {
    await local.insertCustomer(customer.toModel());
  }
}
