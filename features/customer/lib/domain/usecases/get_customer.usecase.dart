import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class GetCustomer {
  final CustomerRepository repository;
  GetCustomer(this.repository);

  Future<Either<Failure, CustomerEntity>> execute(int id) {
    return repository.getCustomer(id);
  }
}
