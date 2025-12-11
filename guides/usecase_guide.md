## Usecase Guide

Panduan ini berpatokan pada implementasi usecase di
`features/customer/lib/domain/usecases`. Ikuti konvensi penamaan dan
struktur kode berikut saat menambahkan usecase baru.

**Konvensi nama file**:
- `<action>_<entity>.usecase.dart` contoh: `create_customer.usecase.dart`

**Struktur umum**:
- Import `package:core/core.dart` untuk `Failure`/`Either` dan helper lain.
- Import `entity` dan `repository` terkait.
- Kelas bernama PascalCase (mis. `CreateCustomer`) dengan konstruktor
  menerima `Repository`.
- Method `call(...)` mengembalikan `Future<Either<Failure, T>>`.

---

## Template usecase

```dart
import 'package:core/core.dart';
import 'package:your_feature/domain/entities/your_entity.dart';
import 'package:your_feature/domain/repositories/your.repository.dart';

class YourUsecase {
  final YourRepository repository;
  YourUsecase(this.repository);

  Future<Either<Failure, YourReturnType>> call(// params) async {
    return await repository.yourRepositoryMethod(// pass params);
  }
}
```

---

## Contoh dari `features/customer` (copy-paste ready)

1) `create_customer.usecase.dart`

```dart
import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class CreateCustomer {
  final CustomerRepository repository;
  CreateCustomer(this.repository);

  Future<Either<Failure, CustomerEntity>> call(CustomerEntity customer,
      {bool? isOffline}) async {
    return await repository.createCustomer(customer, isOffline: isOffline);
  }
}
```

2) `delete_customer.usecase.dart`

```dart
import 'package:core/core.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class DeleteCustomer {
  final CustomerRepository repository;
  DeleteCustomer(this.repository);

  Future<Either<Failure, bool>> call(int id, {bool? isOffline}) async {
    return await repository.deleteCustomer(id, isOffline: isOffline);
  }
}
```

3) `get_customer.usecase.dart`

```dart
import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/domain/repositories/customer.repository.dart';

class GetCustomer {
  final CustomerRepository repository;
  GetCustomer(this.repository);

  Future<Either<Failure, CustomerEntity>> call(int id,
      {bool? isOffline}) async {
    return await repository.getCustomer(id, isOffline: isOffline);
  }
}
```

4) `get_customers.usecase.dart`

```dart
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
    return await repository.getCustomers(query: query, isOffline: isOffline);
  }
}
```

5) `update_customer.usecase.dart`

```dart
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
```

---

## Catatan praktik terbaik
- Letakkan logika domain murni di usecase; panggil repository untuk I/O.
- Selalu kembalikan `Either<Failure, T>` untuk memudahkan penanganan error.
- Gunakan parameter opsional `isOffline` bila repository mendukung mode offline.

Jika ingin, saya bisa juga menambahkan contoh unit test untuk satu usecase.
