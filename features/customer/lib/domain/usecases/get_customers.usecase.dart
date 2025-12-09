import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;
  GetCustomersUseCase(this.repository);
  Future<List<CustomerEntity>> call() => repository.getCustomers();
}
