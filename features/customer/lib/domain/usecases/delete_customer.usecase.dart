import 'package:core/core.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class DeleteCustomer {
  final CustomerRepository repository;
  DeleteCustomer(this.repository);

  Future<Either<Failure, bool>> call(int id, {bool? isOffline}) async {
    return await repository.deleteCustomer(id, isOffline: isOffline);
  }
}
