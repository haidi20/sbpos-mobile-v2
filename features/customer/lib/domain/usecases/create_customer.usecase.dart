import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class CreateCustomer {
  final CustomerRepository repository;
  CreateCustomer(this.repository);

  Future<Either<Failure, CustomerEntity>> call(CustomerEntity customer,
      {bool? isOffline}) async {
    return await repository.createCustomer(customer, isOffline: isOffline);
  }
}
