import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class GetCustomer {
  final CustomerRepository repository;
  GetCustomer(this.repository);

  Future<Either<Failure, CustomerEntity>> call(int id,
      {bool? isOffline}) async {
    try {
      return await repository.getCustomer(id, isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
