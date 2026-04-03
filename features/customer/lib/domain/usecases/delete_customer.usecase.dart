import 'package:core/core.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class DeleteCustomer {
  final CustomerRepository repository;
  DeleteCustomer(this.repository);

  Future<Either<Failure, bool>> call(int id, {bool? isOffline}) async {
    try {
      return await repository.deleteCustomer(id, isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
