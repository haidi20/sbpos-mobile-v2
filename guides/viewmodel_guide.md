# ViewModel Naming Rules

Panduan ini menjelaskan aturan penamaan fungsi untuk `ViewModel` di monorepo ini. Tujuan:
- Konsistensi antara fitur.
- Mudah dibaca dan dipanggil dari controller/screen.

Aturan ringkas (WAJIB diikuti):

1) Getter data awal: `get*`
- Semua fungsi yang mengambil atau menginisialisasi data dari usecase/repository (mis. ambil dari database lokal) harus dinamai dengan prefix `get`.
- Contoh: `getCustomers()` — mengambil daftar pelanggan dari usecase `GetCustomers` dan melakukan seeding jika kosong.

2) Setter state: `set*`
- Semua fungsi yang hanya mengubah state lokal (tidak melakukan I/O jaringan atau DB) harus dinamai dengan prefix `set`.
- Gunakan `state = state.copyWith(...)` di dalam fungsi `set*`.
- Contoh: `setIsAdding(bool)`, `setDraftCustomer(CustomerEntity)`, `setSearchQuery(String)`.

3) Event / aksi (I/O atau perubahan yang membutuhkan usecase): `on*`
- Semua aksi yang memicu usecase, melakukan operasi asynchronous (create/update/delete/get dengan I/O) harus dinamai dengan prefix `on`.
- Contoh: `onCreateCustomer()`, `onUpdateCustomer()`, `onDeleteCustomerById(int?)`, `onSaveOrUpdate()`.

4) Jangan buat alias/`legacy wrappers` yang mempertahankan nama lama. Langsung ganti pemanggilan di file lain ke nama baru `get*`/`set*`/`on*`.

5) Format implementasi
- Gunakan pendekatan berikut dalam `ViewModel`:

	- Constructor menerima usecase yang diperlukan (mis. `GetCustomers`, `CreateCustomer`, `UpdateCustomer`, `DeleteCustomer`).
	- Simpan usecase sebagai field privat (mis. `_getCustomersUsecase`).
	- `get*` melakukan I/O dan kemudian memanggil `set*` untuk memperbarui `state`.
	- `on*` melakukan pemanggilan usecase, menangani hasil `Either<Failure, T>` dan memanggil `state = state.copyWith(...)` sesuai hasil.

6) Contoh ringkas (lihat juga implementasi penuh di fitur):

	- `getCustomers()`
		- Memanggil `_getCustomersUsecase(isOffline: true)`
		- Jika hasil kosong, buat seeding dengan `_createCustomerUsecase(..., isOffline: true)` untuk tiap `initialCustomers`
		- Setelah seeding, panggil kembali `_getCustomersUsecase(isOffline: true)` dan set state

	- `setIsAdding(bool value)`
		- `state = state.copyWith(isAdding: value);`

	- `onCreateCustomer()`
		- Validasi draft
		- Panggil `_createCustomerUsecase(entity, isOffline: true)`
		- Pada success: update `state.customers` dan set `isAdding: false`
		- Pada failure: set `state.error`

7) Rules untuk caller (screen/controller)
- Selalu panggil metode yang sudah dinamai ulang (`get*`, `set*`, `on*`).
- Contoh: jika sebelumnya memanggil `vm.load()` → ganti dengan `vm.getCustomers()`.
- Jika sebelumnya memanggil `vm.startAdd()` → ganti dengan `vm.setIsAdding(true)`.

8) Verifikasi
- Setelah mengganti nama, jalankan `flutter analyze` dan perbaiki semua pemanggilan yang tersisa sampai analisis bersih.

Referensi implementasi (format & gaya):
- [features/transaction/lib/presentation/view_models/transaction_pos.vm.dart](features/transaction/lib/presentation/view_models/transaction_pos.vm.dart)
- [features/customer/lib/presentation/view_models/customer.vm.dart](features/customer/lib/presentation/view_models/customer.vm.dart)

Catatan akhir: ikuti pola ini konsisten pada seluruh fitur baru dan perbaiki pemanggilan pada file lain saat melakukan rename.
