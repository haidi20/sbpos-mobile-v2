import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class UpdateCustomer {
  final CustomerRepository repository;
  UpdateCustomer(this.repository);

  Future<Either<Failure, CustomerEntity>> call(CustomerEntity customer,
      {bool? isOffline}) async {
    return await repository.updateCustomer(customer, isOffline: isOffline);
  }
}
