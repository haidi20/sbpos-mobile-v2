import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class GetCustomers {
  final CustomerRepository repository;
  GetCustomers(this.repository);

  Future<Either<Failure, List<CustomerEntity>>> call({
    String? query,
    bool? isOffline,
  }) async {
    try {
      return await repository.getCustomers(query: query, isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
