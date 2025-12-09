Berikut adalah panduan lengkap dan **baku** untuk penamaan file dan class Use Case dalam Flutter Clean Architecture.

Prinsip utamanya adalah: **Satu File = Satu Use Case = Satu Tindakan Bisnis**.

Rumusnya: **`KataKerja` + `KataBenda`**

### 1\. Tabel Standar Penamaan (CRUD Warehouse)

| Operasi | Nama Class (`PascalCase`) | Nama File (`snake_case`) | Keterangan |
| :--- | :--- | :--- | :--- |
| **Read (List)** | `GetWarehouses` | `get_warehouses.usecase.dart` | Gunakan **Jamak (s)** karena return List. |
| **Read (Detail)**| `GetWarehouse` | `get_warehouse.usecase.dart` | Gunakan **Tunggal** karena return 1 object. |
| **Create** | `CreateWarehouse` | `create_warehouse.usecase.dart` | Atau `AddWarehouse` / `add_warehouse.usecase.dart`. |
| **Update** | `UpdateWarehouse` | `update_warehouse.usecase.dart` | Atau `EditWarehouse`. |
| **Delete** | `DeleteWarehouse` | `delete_warehouse.usecase.dart` | Atau `RemoveWarehouse`. |

-----

### 2\. Contoh Implementasi Code

Berikut adalah isi file yang bersih dan standar. Biasanya kita menggunakan method `execute` atau `call`.

#### A. `get_warehouses.dart` (Ambil Banyak Data)

```dart
import 'package:dartz/dartz.dart'; // Untuk Either
import '../repositories/warehouse_repository.dart';
import '../entities/warehouse_entity.dart';
import '../../../../core/error/failures.dart'; // Sesuaikan path core

class GetWarehouses {
  final WarehouseRepository repository;

  GetWarehouses(this.repository);

  // Return List<WarehouseEntity>
  Future<Either<Failure, List<WarehouseEntity>>> execute() {
    return repository.getWarehouses();
  }
}
```

#### B. `get_warehouse.usecase.dart` (Ambil Satu Data)

```dart
// Import sama...

class GetWarehouse {
  final WarehouseRepository repository;

  GetWarehouse(this.repository);

  // Butuh parameter ID
  Future<Either<Failure, WarehouseEntity>> execute(int id) {
    return repository.getWarehouseById(id);
  }
}
```

#### C. `create_warehouse.usecase.dart` (Tambah Data)

```dart
// Import sama...

class CreateWarehouse {
  final WarehouseRepository repository;

  CreateWarehouse(this.repository);

  // Parameter berupa Entity
  Future<Either<Failure, void>> execute(WarehouseEntity warehouse) {
    return repository.insertWarehouse(warehouse);
  }
}
```

-----

### 3\. Struktur Folder yang Rapi

Di dalam folder `domain/usecases/`, sebaiknya file-file tersebut **tidak dibungkus folder lagi** kecuali usecase-nya sudah sangat banyak (misal \> 10).

```
lib/
├── features/
│   ├── warehouse/
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   ├── get_warehouses.usecase.dart
│   │   │   │   ├── get_warehouse.usecase.dart
│   │   │   │   ├── create_warehouse.usecase.dart
│   │   │   │   ├── update_warehouse.usecase.dart
│   │   │   │   └── delete_warehouse.usecase.dart
```

### 4\. Pertanyaan Umum: Perlukah Suffix "UseCase"?

Anda mungkin sering melihat tutorial menamakan classnya `GetWarehousesUseCase`.

  * **Pilihan A: Tanpa Suffix (`GetWarehouses`)** -\> **Direkomendasikan.**

      * Lebih singkat.
      * Karena sudah ada di folder `usecases`, suffix itu jadi redundan (pemborosan kata).
      * Contoh panggil di VM: `getWarehouses.execute()`.

  * **Pilihan B: Dengan Suffix (`GetWarehousesUseCase`)**

      * Boleh dipakai jika Anda khawatir nama class bentrok dengan nama method lain.
      * Tapi di Dart, nama file import bisa di-alias (`as`), jadi bentrok nama jarang terjadi.

**Kesimpulan untuk Project Anda:**
Gunakan **Pilihan A** (Tanpa Suffix) agar kode lebih bersih seperti contoh di atas.

1.  Class: `GetWarehouses`
2.  File: `get_warehouses.usecase.dart`
3.  Method: `execute()`
