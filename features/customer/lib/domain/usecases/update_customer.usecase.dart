import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class UpdateCustomer {
  final CustomerRepository repository;
  UpdateCustomer(this.repository);

  Future<Either<Failure, CustomerEntity>> call(CustomerEntity customer,
      {bool? isOffline}) async {
    try {
      return await repository.updateCustomer(customer, isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
