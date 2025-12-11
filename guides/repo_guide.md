## Repository Guide

Panduan ini mencontoh implementasi repository pada
`features/customer`. Ikuti pola berikut saat membuat repository baru
di fitur lain.

**Konvensi nama file**:
- `your_entity.repository.dart` untuk abstrak (interface) repository.
- `your_entity.repository.impl.dart` untuk implementasi repository.

**Struktur umum**:
- Abstrak repository mendefinisikan method yang mengembalikan
  `Future<Either<Failure, T>>` atau varian yang sesuai.
- Implementasi repository melakukan orkestrasi antara data source
  (`remote` dan `local`), `NetworkInfo`, dan mengubah model ↔ entity.
- Tangani exception spesifik (`ServerException`, `NetworkException`),
  lakukan fallback ke data lokal bila memungkinkan.

---

## Contoh: `CustomerRepository` (abstrak)

File: `features/customer/lib/domain/repositories/customer.repository.dart`

```dart
import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers(
      {String? query, bool? isOffline});
  Future<Either<Failure, CustomerEntity>> getCustomer(int id,
      {bool? isOffline});
  Future<Either<Failure, CustomerEntity>> createCustomer(
      CustomerEntity customer,
      {bool? isOffline});
  Future<Either<Failure, CustomerEntity>> updateCustomer(
      CustomerEntity customer,
      {bool? isOffline});
  Future<Either<Failure, bool>> deleteCustomer(int id, {bool? isOffline});
}
```

---

## Contoh: `CustomerRepositoryImpl` (implementasi)

File: `features/customer/lib/data/repositories/customer.repository.impl.dart`

```dart
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:customer/data/models/customer.model.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/data/responses/customer.response.dart';
import 'package:customer/domain/repositories/customer.repository.dart';
import 'package:customer/data/datasources/local_customer.datasource.dart';
import 'package:customer/data/datasources/remote_customer.datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remote;
  final LocalCustomerDataSource local;

  static final Logger _logger = Logger('CustomerRepositoryImpl');

  CustomerRepositoryImpl({
    required this.remote,
    required this.local,
  });

  Future<List<CustomerEntity>> _getLocalEntities() async {
    final localResp = await local.getCustomers();
    return localResp.map((model) => CustomerEntity.fromModel(model)).toList();
  }

  Future<List<CustomerModel>?> _saveToLocal(
      List<CustomerModel>? customers) async {
    if (customers != null && customers.isNotEmpty) {
      List<CustomerModel> inserted = [];
      for (var c in customers) {
        try {
          final ins = await local.insertCustomer(c);
          if (ins != null) inserted.add(ins);
        } catch (e, st) {
          _logger.warning('Gagal insert customer lokal: $e', e, st);
        }
      }

      if (inserted.isEmpty) {
        _logger.warning(
            'Tidak ada pelanggan yang tersinkron ke basis data lokal.');
        return null;
      }

      return inserted;
    }
    return null;
  }

  Future<Either<Failure, List<CustomerEntity>>> _fallbackToLocal({
    Failure fallbackFailure = const NetworkFailure(),
  }) async {
    final localEntities = await _getLocalEntities();
    if (localEntities.isNotEmpty) {
      return Right(localEntities);
    }
    return Left(fallbackFailure);
  }

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    String? query,
    bool? isOffline,
  }) async {
    if (isOffline == true) {
      final localEntities = await _getLocalEntities();
      return Right(localEntities);
    }

    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final CustomerResponse resp = await remote.fetchCustomers();
        if (resp.success != true || resp.data == null) {
          return _fallbackToLocal(fallbackFailure: const ServerFailure());
        }
        final models = resp.data!;
        if (models.isNotEmpty) {
          final saved = await _saveToLocal(models);
          return Right(saved!.map((m) => CustomerEntity.fromModel(m)).toList());
        } else {
          return _fallbackToLocal(fallbackFailure: const ServerFailure());
        }
      } on ServerException {
        return _fallbackToLocal(fallbackFailure: const ServerFailure());
      } on NetworkException {
        return _fallbackToLocal(fallbackFailure: const NetworkFailure());
      } catch (e, st) {
        _logger.severe('Error saat mengambil data customer:', e, st);
        return _fallbackToLocal(fallbackFailure: const UnknownFailure());
      }
    } else {
      return _fallbackToLocal(fallbackFailure: const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomer(int id,
      {bool? isOffline}) async {
    if (isOffline == true) {
      final localModel = await local.getCustomerById(id);
      if (localModel != null) {
        return Right(CustomerEntity.fromModel(localModel));
      }
      return const Left(UnknownFailure());
    }

    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      final localModel = await local.getCustomerById(id);
      if (localModel != null) {
        return Right(CustomerEntity.fromModel(localModel));
      }
      return const Left(NetworkFailure());
    }

    try {
      final resp = await remote.getCustomer(id);

      if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
        final localModel = await local.getCustomerById(id);
        if (localModel != null) {
          return Right(CustomerEntity.fromModel(localModel));
        }
        return const Left(ServerFailure());
      }

      final model = resp.data!.first;
      await local.insertCustomer(model);
      return Right(CustomerEntity.fromModel(model));
    } on ServerException {
      final localModel = await local.getCustomerById(id);
      if (localModel != null) {
        return Right(CustomerEntity.fromModel(localModel));
      }
      return const Left(ServerFailure());
    } on NetworkException {
      final localModel = await local.getCustomerById(id);
      if (localModel != null) {
        return Right(CustomerEntity.fromModel(localModel));
      }
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan saat mengambil customer:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer(
      CustomerEntity customer,
      {bool? isOffline}) async {
    try {
      final model = customer.toModel();
      final localInserted = await local.insertCustomer(model);
      if (localInserted == null) {
        if (kDebugMode) {
          debugPrint(
              'createCustomer: local.insertCustomer mengembalikan NULL untuk model: ${model.toJson()}');
        }
        return const Left(UnknownFailure());
      }

      if (isOffline == true) {
        final localId = localInserted.id;
        if (localId != null) {
          await local.clearSyncedAt(localId);
        }
        return Right(CustomerEntity.fromModel(localInserted));
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        final localId = localInserted.id;
        if (localId != null) {
          await local.clearSyncedAt(localId);
        }
        return Right(CustomerEntity.fromModel(localInserted));
      }

      try {
        final CustomerResponse resp = await remote.postCustomer(model.toJson());
        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          final localId = localInserted.id;
          if (localId != null) {
            await local.clearSyncedAt(localId);
          }
          return Right(CustomerEntity.fromModel(localInserted));
        }
        final created = resp.data!.first;
        final syncAt = DateTime.now();
        final idServer = created.idServer ?? created.id;
        await local.updateCustomer({
          'id': localInserted.id,
          'id_server': idServer,
          'synced_at': syncAt.toIso8601String(),
        });
        final updatedLocal = await local.getCustomerById(localInserted.id ?? 0);
        return Right(CustomerEntity.fromModel(updatedLocal ?? localInserted));
      } on ServerException {
        final localId = localInserted.id;
        if (localId != null) {
          await local.clearSyncedAt(localId);
        }
        return Right(CustomerEntity.fromModel(localInserted));
      } on NetworkException {
        final localId = localInserted.id;
        if (localId != null) {
          await local.clearSyncedAt(localId);
        }
        return Right(CustomerEntity.fromModel(localInserted));
      }
    } catch (e, st) {
      _logger.severe('Error saat menyimpan customer:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomer(
      CustomerEntity customer,
      {bool? isOffline}) async {
    try {
      final model = customer.toModel();

      if (model.id == null) {
        _logger.info(
            'updateCustomer: tidak ada id lokal, dialihkan ke createCustomer');
        return await createCustomer(customer, isOffline: isOffline);
      }

      final mapForUpdate = Map<String, dynamic>.from(model.toInsertDbLocal())
        ..['id'] = model.id;

      try {
        final updateCount = await local.updateCustomer(mapForUpdate);
        if (updateCount == 0) {
          _logger.warning(
              'updateCustomer: pembaruan lokal tidak memengaruhi baris apa pun, kembali ke createCustomer');
          return await createCustomer(customer, isOffline: isOffline);
        }
      } catch (e, st) {
        _logger.warning(
            'updateCustomer: pembaruan lokal melempar error, kembali ke create',
            e,
            st);
        return await createCustomer(customer, isOffline: isOffline);
      }

      if (isOffline == true) {
        if (model.id != null) {
          await local.clearSyncedAt(model.id!);
        }
        final localCust = await local.getCustomerById(model.id ?? 0);
        if (localCust == null) {
          _logger.warning(
              'updateCustomer: customer lokal yang diharapkan tidak ditemukan, membuat via createCustomer');
          return await createCustomer(customer, isOffline: true);
        }
        return Right(CustomerEntity.fromModel(localCust));
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        if (model.id != null) {
          await local.clearSyncedAt(model.id!);
        }
        final localCust = await local.getCustomerById(model.id ?? 0);
        if (localCust == null) {
          return const Left(NetworkFailure());
        }
        return Right(CustomerEntity.fromModel(localCust));
      }

      try {
        final resp = await remote.updateCustomer(model.id ?? 0, model.toJson());
        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          if (model.id != null) {
            await local.clearSyncedAt(model.id!);
          }
          final localCust = await local.getCustomerById(model.id ?? 0);
          if (localCust == null) {
            return const Left(ServerFailure());
          }
          return Right(CustomerEntity.fromModel(localCust));
        }

        final updatedLocal = await local.getCustomerById(model.id ?? 0);
        if (updatedLocal == null) {
          return const Left(UnknownFailure());
        }
        return Right(CustomerEntity.fromModel(updatedLocal));
      } on ServerException {
        if (model.id != null) {
          await local.clearSyncedAt(model.id!);
        }
        final localCust = await local.getCustomerById(model.id ?? 0);
        if (localCust == null) {
          return const Left(ServerFailure());
        }
        return Right(CustomerEntity.fromModel(localCust));
      } on NetworkException {
        if (model.id != null) {
          await local.clearSyncedAt(model.id!);
        }
        final localCust = await local.getCustomerById(model.id ?? 0);
        if (localCust == null) {
          return const Left(NetworkFailure());
        }
        return Right(CustomerEntity.fromModel(localCust));
      }
    } catch (e, st) {
      _logger.severe('Kesalahan saat memperbarui customer:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCustomer(int id,
      {bool? isOffline}) async {
    try {
      await local.deleteCustomer(id);

      if (isOffline == true) {
        return const Right(true);
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Right(true);
      }

      try {
        final resp = await remote.deleteCustomer(id);
        if (resp.success == true) {
          return const Right(true);
        }
        return const Right(true);
      } on ServerException {
        return const Right(true);
      } on NetworkException {
        return const Right(true);
      }
    } catch (e, st) {
      _logger.severe('Kesalahan saat menghapus customer:', e, st);
      return const Left(UnknownFailure());
    }
  }
}
```

---

## Praktik terbaik singkat
- Gunakan `NetworkInfo` untuk memutuskan memakai remote atau fallback ke local.
- Tangani exception secara spesifik dan catat (`Logger`) untuk debugging.
- Simpan model hasil remote ke local untuk sinkronisasi offline-first.
- Biarkan repository mengembalikan `Either<Failure, T>` agar usecase mudah
  menangani error.
- isOffline merupakan proses IO hanya ke local tanpa remote.
