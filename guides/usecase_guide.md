Berikut adalah panduan lengkap dan **baku** untuk penamaan file dan class Use Case dalam Flutter Clean Architecture.

Prinsip utamanya adalah: **Satu File = Satu Use Case = Satu Tindakan Bisnis**.

Rumusnya: **`KataKerja` + `KataBenda`**

### 1\. Tabel Standar Penamaan (CRUD Outlet)

| Operasi | Nama Class (`PascalCase`) | Nama File (`snake_case`) | Keterangan |
| :--- | :--- | :--- | :--- |
| **Read (List)** | `GetOutlets` | `get_outlets.usecase.dart` | Gunakan **Jamak (s)** karena return List. |
| **Read (Detail)**| `GetOutlet` | `get_outlet.usecase.dart` | Gunakan **Tunggal** karena return 1 object. |
| **Create** | `CreateOutlet` | `create_outlet.usecase.dart` | Atau `AddOutlet` / `add_outlet.usecase.dart`. |
| **Update** | `UpdateOutlet` | `update_outlet.usecase.dart` | Atau `EditOutlet`. |
| **Delete** | `DeleteOutlet` | `delete_outlet.usecase.dart` | Atau `RemoveOutlet`. |

-----

### 2\. Contoh Implementasi Code

Berikut adalah isi file yang bersih dan standar. Biasanya kita menggunakan method `execute` atau `call`.

#### A. `get_outlets.usecase.dart` (Ambil Banyak Data)

```dart
import 'package:dartz/dartz.dart'; // Untuk Either
import '../repositories/outlet_repository.dart';
import '../entities/outlet_entity.dart';
import '../../../../core/error/failures.dart'; // Sesuaikan path core

class GetOutlets {
  final OutletRepository repository;

  GetOutlets(this.repository);

  // Return List<OutletEntity>
  Future<Either<Failure, List<OutletEntity>>> execute({bool isOffline = false}) {
    return repository.getDataOutlets();
  }
}
```

#### B. `get_outlet.usecase.dart` (Ambil Satu Data)

```dart
// Import sama...

class GetOutlet {
  final OutletRepository repository;

  GetOutlet(this.repository);

  // Butuh parameter ID
  Future<Either<Failure, OutletEntity>> execute(int id, {bool isOffline = false}) {
    return repository.getDataOutlets();
  }
}
```

#### C. `create_outlet.usecase.dart` (Tambah Data)

```dart
// Import sama...

class CreateOutlet {
  final OutletRepository repository;

  CreateOutlet(this.repository);

  // Parameter berupa Entity
  Future<Either<Failure, void>> execute(OutletEntity outlet, {bool isOffline = false}) {
    return repository.insertOutlet(outlet, isOffline: isOffline);
  }
}
```

-----

### 3\. Struktur Folder yang Rapi

Di dalam folder `domain/usecases/`, sebaiknya file-file tersebut **tidak dibungkus folder lagi** kecuali usecase-nya sudah sangat banyak (misal \> 10).

```
lib/
├── features/
│   ├── outlet/
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   ├── get_outlets.usecase.dart
│   │   │   │   ├── get_outlet.usecase.dart
│   │   │   │   ├── create_outlet.usecase.dart
│   │   │   │   ├── update_outlet.usecase.dart
│   │   │   │   └── delete_outlet.usecase.dart
```

### 4\. Pertanyaan Umum: Perlukah Suffix "UseCase"?

Anda mungkin sering melihat tutorial menamakan classnya `GetOutletsUseCase`.

  * **Pilihan A: Tanpa Suffix (`GetOutlets`)** -\> **Direkomendasikan.**

      * Lebih singkat.
      * Karena sudah ada di folder `usecases`, suffix itu jadi redundan (pemborosan kata).
      * Contoh panggil di VM: `getOutlets.execute()`.

  * **Pilihan B: Dengan Suffix (`GetOutletUseCase`)**

      * Boleh dipakai jika Anda khawatir nama class bentrok dengan nama method lain.
      * Tapi di Dart, nama file import bisa di-alias (`as`), jadi bentrok nama jarang terjadi.

**Kesimpulan untuk Project Anda:**
Gunakan **Pilihan A** (Tanpa Suffix) agar kode lebih bersih seperti contoh di atas.

1.  Class: `GetOutlets`
2.  File: `get_outlets.usecase.dart`
3.  Method: `execute()`
