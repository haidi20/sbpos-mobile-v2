# Panduan Penulisan Test untuk Fitur Cart (onAddToCart & onStoreLocal)

Panduan ini berfokus pada penulisan test untuk skenario `onAddToCart` dan `onStoreLocal` pada aplikasi sbpos_mobile_v2, dengan cakupan mulai dari ViewModel, UseCase, Repository Implementation, Local Data Source, hingga DAO. Semua test menggunakan bahasa Indonesia dan menguji operasi nyata (insert, read, update, delete) ke database lokal.

---

## 1. Test ViewModel (CartViewModel)

### Skenario: onAddToCart

- **Test:** Menambah item ke cart, memastikan state cart bertambah.
- **Langkah:**
    1. Inisialisasi CartViewModel dengan dependensi mock.
    2. Panggil `onAddToCart` dengan produk contoh.
    3. Verifikasi state cart berisi produk yang ditambahkan.

### Skenario: onStoreLocal

- **Test:** Menyimpan cart ke database lokal, memastikan data tersimpan.
- **Langkah:**
    1. Panggil `onStoreLocal` setelah menambah item.
    2. Verifikasi data cart tersimpan di database lokal.

---

## 2. Test UseCase (AddToCartUseCase, StoreCartLocalUseCase)

### Skenario: AddToCartUseCase

- **Test:** Menambah produk ke cart, hasil sesuai ekspektasi.
- **Langkah:**
    1. Panggil usecase dengan produk.
    2. Pastikan produk masuk ke list cart.

### Skenario: StoreCartLocalUseCase

- **Test:** Menyimpan cart ke database lokal.
- **Langkah:**
    1. Panggil usecase dengan data cart.
    2. Verifikasi data tersimpan di local data source.

---

## 3. Test Repository Implementation (CartRepositoryImpl)

### Skenario: Insert, Read, Update, Delete Cart

- **Test:** CRUD cart ke database lokal.
- **Langkah:**
    1. Insert cart, pastikan data masuk.
    2. Read cart, pastikan data sesuai.
    3. Update cart, pastikan perubahan tersimpan.
    4. Delete cart, pastikan data terhapus.

---

## 4. Test Local Data Source (CartLocalDataSourceImpl)

### Skenario: CRUD Cart

- **Test:** Operasi insert, read, update, delete ke database lokal.
- **Langkah:**
    1. Insert data cart.
    2. Ambil data cart, pastikan sesuai.
    3. Update data cart, cek perubahan.
    4. Hapus data cart, pastikan kosong.

---

## 5. Test DAO (CartDao)

### Skenario: CRUD Cart Table

- **Test:** Insert, query, update, delete pada tabel cart.
- **Langkah:**
    1. Insert data ke tabel cart.
    2. Query data, pastikan data benar.
    3. Update data, cek hasil update.
    4. Delete data, pastikan data hilang.

---

## Contoh Kode Test (Flutter + sqflite + mockito)
