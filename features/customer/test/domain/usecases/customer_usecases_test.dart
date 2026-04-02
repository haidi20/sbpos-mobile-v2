import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';
import 'package:customer/domain/usecases/create_customer.usecase.dart';
import 'package:customer/domain/usecases/delete_customer.usecase.dart';
import 'package:customer/domain/usecases/get_customer.usecase.dart';
import 'package:customer/domain/usecases/get_customers.usecase.dart';
import 'package:customer/domain/usecases/update_customer.usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCustomerRepository implements CustomerRepository {
  FakeCustomerRepository({
    this.onCreateCustomer,
    this.onDeleteCustomer,
    this.onGetCustomer,
    this.onGetCustomers,
    this.onUpdateCustomer,
  });

  final Future<Either<Failure, CustomerEntity>> Function(
    CustomerEntity customer, {
    bool? isOffline,
  })? onCreateCustomer;
  final Future<Either<Failure, bool>> Function(
    int id, {
    bool? isOffline,
  })? onDeleteCustomer;
  final Future<Either<Failure, CustomerEntity>> Function(
    int id, {
    bool? isOffline,
  })? onGetCustomer;
  final Future<Either<Failure, List<CustomerEntity>>> Function({
    String? query,
    bool? isOffline,
  })? onGetCustomers;
  final Future<Either<Failure, CustomerEntity>> Function(
    CustomerEntity customer, {
    bool? isOffline,
  })? onUpdateCustomer;

  static const sampleCustomer = CustomerEntity(
    id: 1,
    idServer: 11,
    name: 'Budi',
    phone: '08123456789',
    note: 'Pelanggan loyal',
    email: 'budi@sbpos.test',
  );

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer(
    CustomerEntity customer, {
    bool? isOffline,
  }) {
    final handler = onCreateCustomer;
    if (handler == null) {
      return Future.value(Right(customer));
    }
    return handler(customer, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, bool>> deleteCustomer(
    int id, {
    bool? isOffline,
  }) {
    final handler = onDeleteCustomer;
    if (handler == null) {
      return Future.value(const Right(true));
    }
    return handler(id, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomer(
    int id, {
    bool? isOffline,
  }) {
    final handler = onGetCustomer;
    if (handler == null) {
      return Future.value(const Right(sampleCustomer));
    }
    return handler(id, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    String? query,
    bool? isOffline,
  }) {
    final handler = onGetCustomers;
    if (handler == null) {
      return Future.value(const Right([sampleCustomer]));
    }
    return handler(query: query, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomer(
    CustomerEntity customer, {
    bool? isOffline,
  }) {
    final handler = onUpdateCustomer;
    if (handler == null) {
      return Future.value(Right(customer));
    }
    return handler(customer, isOffline: isOffline);
  }
}

Future<void> expectLeftFailure<T>(
  Future<Either<Failure, T>> Function() action,
  Matcher matcher,
) async {
  final result = await action();
  result.fold(
    (failure) => expect(failure, matcher),
    (_) => fail('Expected Left result'),
  );
}

void main() {
  const customer = FakeCustomerRepository.sampleCustomer;

  group('Customer usecases', () {
    test('CreateCustomer returns repository entity on success', () async {
      final repository = FakeCustomerRepository();

      final result = await CreateCustomer(repository)(customer);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, customer),
      );
    });

    test('CreateCustomer maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeCustomerRepository(
        onCreateCustomer: (customer, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => CreateCustomer(repository)(customer),
        same(failure),
      );
    });

    test('CreateCustomer maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeCustomerRepository(
        onCreateCustomer: (customer, {isOffline}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => CreateCustomer(repository)(customer),
        isA<UnknownFailure>(),
      );
    });

    test('DeleteCustomer returns repository bool on success', () async {
      final repository = FakeCustomerRepository();

      final result = await DeleteCustomer(repository)(customer.id!);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, isTrue),
      );
    });

    test('DeleteCustomer maps thrown Failure into Left', () async {
      const failure = NetworkFailure();
      final repository = FakeCustomerRepository(
        onDeleteCustomer: (id, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => DeleteCustomer(repository)(customer.id!),
        same(failure),
      );
    });

    test('DeleteCustomer maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeCustomerRepository(
        onDeleteCustomer: (id, {isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => DeleteCustomer(repository)(customer.id!),
        isA<UnknownFailure>(),
      );
    });

    test('GetCustomer returns repository entity on success', () async {
      final repository = FakeCustomerRepository();

      final result = await GetCustomer(repository)(customer.id!);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, customer),
      );
    });

    test('GetCustomer maps thrown Failure into Left', () async {
      const failure = LocalValidation('customer tidak valid');
      final repository = FakeCustomerRepository(
        onGetCustomer: (id, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetCustomer(repository)(customer.id!),
        same(failure),
      );
    });

    test('GetCustomer maps unexpected exception into UnknownFailure', () async {
      final repository = FakeCustomerRepository(
        onGetCustomer: (id, {isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetCustomer(repository)(customer.id!),
        isA<UnknownFailure>(),
      );
    });

    test('GetCustomers returns repository list on success', () async {
      final repository = FakeCustomerRepository();

      final result = await GetCustomers(repository)();

      result.fold(
        (_) => fail('Expected Right result'),
        (customers) => expect(customers, const [customer]),
      );
    });

    test('GetCustomers maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeCustomerRepository(
        onGetCustomers: ({query, isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetCustomers(repository)(),
        same(failure),
      );
    });

    test('GetCustomers maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeCustomerRepository(
        onGetCustomers: ({query, isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetCustomers(repository)(),
        isA<UnknownFailure>(),
      );
    });

    test('UpdateCustomer returns repository entity on success', () async {
      final repository = FakeCustomerRepository();

      final result = await UpdateCustomer(repository)(customer);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, customer),
      );
    });

    test('UpdateCustomer maps thrown Failure into Left', () async {
      const failure = NetworkFailure();
      final repository = FakeCustomerRepository(
        onUpdateCustomer: (customer, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => UpdateCustomer(repository)(customer),
        same(failure),
      );
    });

    test('UpdateCustomer maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeCustomerRepository(
        onUpdateCustomer: (customer, {isOffline}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => UpdateCustomer(repository)(customer),
        isA<UnknownFailure>(),
      );
    });
  });
}
