import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class GetCustomers {
  final CustomerRepository repository;
  GetCustomers(this.repository);

  Future<Either<Failure, List<CustomerEntity>>> call({bool? isOffline}) async {
    return await repository.getCustomers(isOffline: isOffline);
  }
}
