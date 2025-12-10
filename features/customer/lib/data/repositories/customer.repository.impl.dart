import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';
import 'package:customer/data/datasources/local_customer.datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final LocalCustomerDataSource local;
  CustomerRepositoryImpl(this.local);

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers() async {
    try {
      final models = await local.getCustomers();
      return Right(models.map((m) => CustomerEntity.fromModel(m)).toList());
    } catch (e, st) {
      Logger('CustomerRepositoryImpl').severe('getCustomers error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomer(int id) async {
    try {
      final model = await local.getCustomerById(id);
      if (model == null) return const Left(UnknownFailure());
      return Right(CustomerEntity.fromModel(model));
    } catch (e, st) {
      Logger('CustomerRepositoryImpl').severe('getCustomer error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer(
      CustomerEntity customer) async {
    try {
      final inserted = await local.insertCustomer(customer.toModel());
      if (inserted == null) return const Left(UnknownFailure());
      return Right(CustomerEntity.fromModel(inserted));
    } catch (e, st) {
      Logger('CustomerRepositoryImpl').severe('createCustomer error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomer(
      CustomerEntity customer) async {
    try {
      final map = customer.toModel().toInsertDbLocal();
      if (customer.id != null) {
        map['id'] = customer.id;
      }
      final count = await local.updateCustomer(map);
      if (count == 0) return const Left(UnknownFailure());
      final updated = await local.getCustomerById(customer.id ?? 0);
      if (updated == null) return const Left(UnknownFailure());
      return Right(CustomerEntity.fromModel(updated));
    } catch (e, st) {
      Logger('CustomerRepositoryImpl').severe('updateCustomer error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCustomer(int id) async {
    try {
      final count = await local.deleteCustomer(id);
      return Right(count > 0);
    } catch (e, st) {
      Logger('CustomerRepositoryImpl').severe('deleteCustomer error', e, st);
      return const Left(UnknownFailure());
    }
  }
}
