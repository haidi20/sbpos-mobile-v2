# Panduan Menu Setting SB POS

Dokumen ini disusun berdasarkan implementasi aplikasi yang ada di source code per 1 April 2026. Isi panduan ini menjelaskan fitur-fitur yang saat ini benar-benar tersedia pada modul `setting`, beserta alur penggunaan, data yang ditampilkan, validasi input, dan catatan teknis penting.

Cakupan dokumen ini berfokus pada:

- fitur yang aktif dan terlihat pada UI menu `Setting`,
- perilaku operasional yang benar-benar terjadi saat pengguna berinteraksi,
- batasan implementasi saat ini berdasarkan source code yang aktif dipakai aplikasi.

Dokumen ini tidak merinci seluruh helper, widget internal kecil, file backup, atau perilaku yang belum diimplementasikan.

## 1. Ringkasan Menu Setting

Menu `Setting` pada aplikasi saat ini berfungsi sebagai pusat navigasi ke halaman pengaturan UI berikut:

1. `Informasi Toko`
2. `Printer & Struk`
3. `Metode Pembayaran`
4. `Ubah Profil`
5. `Notifikasi`
6. `Ubah PIN / Password`
7. `Bantuan Pengguna`
8. `Keluar Aplikasi`

Di bagian bawah halaman, aplikasi juga menampilkan teks versi statis:

- `SBPOS App v2`

Catatan penting:

- modul ini sudah tersedia dan terhubung ke router utama aplikasi,
- sebagian besar fitur pada modul ini masih berupa UI lokal dan belum terhubung ke API, database, Bluetooth, atau persistence lokal,
- beberapa tombol simpan/aksi masih berupa placeholder atau hanya menutup halaman.

## 2. Lokasi dan Cara Akses

Menu `Setting` dapat diakses dari dashboard aplikasi:

1. buka halaman `Dashboard`,
2. pada bagian `Menu Cepat`, pilih tombol `Pengaturan`,
3. aplikasi akan menavigasikan pengguna ke route `/settings`.

Route yang terkait langsung dengan modul ini:

- `/settings`
- `/settings/store`
- `/settings/printer`
- `/settings/payment`
- `/settings/profile`
- `/settings/notification`
- `/settings/security`
- `/settings/help`

## 3. Prasyarat Umum

Agar pengguna dapat membuka dan menjelajahi menu `Setting`, kondisi berikut perlu terpenuhi:

- pengguna sudah berada di aplikasi utama,
- navigasi `GoRouter` aktif,
- pengguna memiliki akses ke dashboard atau route pengaturan.

Untuk implementasi yang ada saat ini, fitur `setting` tidak mensyaratkan:

- koneksi internet aktif,
- token akses untuk submit data,
- Bluetooth aktif,
- printer Bluetooth yang sudah ter-pair.

Itu karena perilaku backend/peripheral tersebut belum diimplementasikan di modul `setting` saat ini.

## 4. Struktur Menu Setting

| Menu | Fungsi Utama | Status Implementasi Saat Ini |
| --- | --- | --- |
| Informasi Toko | Menampilkan form data toko | UI statis, belum ada simpan ke backend |
| Printer & Struk | Menampilkan mock printer dan opsi cetak | UI lokal, belum ada integrasi printer |
| Metode Pembayaran | Toggle metode pembayaran | State lokal di memori |
| Ubah Profil | Menampilkan form profil pengguna | UI statis, tombol simpan belum aktif |
| Notifikasi | Toggle preferensi notifikasi | State lokal di memori |
| Ubah PIN / Password | Menampilkan form keamanan | UI lokal, tombol hanya kembali |
| Bantuan Pengguna | Menampilkan FAQ dan CTA WhatsApp | UI statis, aksi belum aktif |
| Keluar Aplikasi | Opsi logout | Tombol ada, aksi belum diimplementasikan |

## 5. Detail Fitur

### 5.1. Halaman Utama Setting

### Tujuan

Halaman utama `Setting` berfungsi sebagai pintu masuk ke seluruh sub-menu pengaturan.

### Informasi yang Ditampilkan

Pada halaman utama, pengguna akan melihat:

- tombol kembali,
- judul `Pengaturan`,
- kartu profil dengan data statis:
  - nama `Budi Santoso`,
  - role `Kasir - Shift Pagi`,
  - badge `Online`,
  - avatar dari `https://picsum.photos/200/200?random=user`,
- grup menu `Toko & Perangkat`,
- grup menu `Akun & Keamanan`,
- grup menu `Lainnya`,
- teks footer `SBPOS App v2`.

### Navigasi yang Tersedia

Halaman ini menyediakan navigasi ke:

- `Informasi Toko`
- `Printer & Struk`
- `Metode Pembayaran`
- `Ubah Profil`
- `Notifikasi`
- `Ubah PIN / Password`
- `Bantuan Pengguna`

### Catatan Penting

- item `Keluar Aplikasi` sudah tampil di UI, tetapi aksi logout belum diimplementasikan,
- seluruh data profil dan sublabel menu masih hard-coded,
- tidak ada loading, fetch data, atau error state pada halaman utama.

### 5.2. Informasi Toko

### Tujuan

Halaman ini digunakan untuk menampilkan form data toko dan cabang.

### Field yang Ditampilkan

Field yang tersedia:

- `Nama Toko`
- `Cabang`
- `Alamat Lengkap`
- `Nomor Telepon`

Nilai awal yang ditampilkan:

- `SB Coffee`
- `Jakarta Selatan`
- `Jl. Sudirman No. 45, SCBD, Jakarta Selatan`
- `0812-3456-7890`

Komponen tambahan:

- placeholder logo toko,
- tombol `Ubah Logo`,
- tombol `Simpan Perubahan`.

### Perilaku Sistem

- tombol `Ubah Logo` belum memiliki aksi,
- tombol `Simpan Perubahan` hanya menjalankan `Navigator.pop(context)`,
- field dapat diedit di UI, tetapi perubahan tidak disimpan ke state global, local storage, atau backend.

### Validasi

Saat ini tidak ada validasi form, misalnya:

- tidak ada validasi field wajib,
- tidak ada validasi format nomor telepon,
- tidak ada snackbar sukses/gagal.

### 5.3. Printer & Struk

### Tujuan

Halaman ini menampilkan tampilan pengaturan printer dan struk.

### Informasi yang Ditampilkan

Pengguna akan melihat:

- judul `Printer & Struk`,
- panel status `Mencari Printer...`,
- teks bantuan `Pastikan bluetooth printer aktif`,
- section `Perangkat Terhubung`,
- satu perangkat statis:
  - `Epson TM-T82`
  - status `Terhubung`,
- tombol `Putus`,
- section `Pengaturan Cetak`,
- switch `Auto Print Struk`,
- switch `Cetak Logo Toko`,
- dropdown `Lebar Kertas`,
- tombol `Test Print`.

### Perilaku Sistem

- `Auto Print Struk` dan `Cetak Logo Toko` tersimpan hanya di state widget selama halaman masih terbuka,
- tombol `Putus` belum memiliki aksi,
- tombol `Test Print` belum memiliki aksi,
- dropdown lebar kertas selalu menggunakan nilai tetap `80mm`,
- callback `onChanged` dropdown belum mengubah state, sehingga pemilihan kertas tidak benar-benar tersimpan.

### Catatan Penting

- belum ada implementasi scan Bluetooth,
- belum ada daftar printer dinamis,
- belum ada persistence printer default,
- belum ada pengiriman byte cetak,
- belum ada integrasi plugin printer, Bluetooth, atau `SharedPreferences`.

### 5.4. Metode Pembayaran

### Tujuan

Halaman ini digunakan untuk menampilkan daftar metode pembayaran dan mengubah status aktif/nonaktif setiap metode.

### Data yang Ditampilkan

Daftar metode pembayaran yang ada saat ini:

- `Tunai (Cash)` aktif
- `QRIS` aktif
- `Kartu Debit` aktif
- `Kartu Kredit` nonaktif
- `Transfer Bank` nonaktif

### Perilaku Sistem

- setiap item dapat ditekan untuk toggle status `active`,
- state disimpan hanya di list lokal dalam `StatefulWidget`,
- beberapa metode bisa aktif bersamaan,
- tidak ada proses submit atau sinkronisasi ke backend.

### Validasi

Saat ini tidak ada validasi atau aturan bisnis, misalnya:

- tidak ada batas minimal satu metode aktif,
- tidak ada konfirmasi sebelum mengubah status,
- tidak ada notifikasi sukses/gagal.

### 5.5. Ubah Profil

### Tujuan

Halaman ini menampilkan form edit profil pengguna.

### Field yang Ditampilkan

Field yang tersedia:

- `Nama Lengkap`
- `ID Karyawan`
- `Email`
- `No. Handphone`

Nilai awal yang ditampilkan:

- `Budi Santoso`
- `EMP-2023-001`
- `budi@sbpos.com`
- `0812-9999-8888`

Komponen tambahan:

- avatar dari `https://picsum.photos/200/200?random=user`,
- ikon kamera dekoratif,
- tombol `Simpan Profil`.

### Perilaku Sistem

- field `ID Karyawan` berada dalam kondisi `enabled: false`,
- field lain bisa diedit pada UI,
- tombol `Simpan Profil` belum memiliki aksi.

### Validasi

Saat ini belum ada validasi:

- format email,
- format nomor telepon,
- field wajib,
- perubahan data sebelum submit.

### 5.6. Notifikasi

### Tujuan

Halaman ini digunakan untuk mengubah preferensi notifikasi lokal pada UI.

### Toggle yang Tersedia

- `Push Notifikasi`
- `Suara Transaksi`
- `Alert Stok Menipis`

Nilai awal semua toggle:

- `true`

### Perilaku Sistem

- toggle langsung mengubah state lokal dengan `setState`,
- perubahan hanya hidup selama halaman dan widget instance masih aktif,
- tidak ada persistence lokal maupun remote.

### Catatan Penting

- tidak ada permission notification,
- tidak ada integrasi sistem notifikasi,
- tidak ada sinkronisasi preferensi ke akun pengguna.

### 5.7. Ubah PIN / Password

### Tujuan

Halaman ini menampilkan form keamanan untuk mengganti PIN.

### Informasi yang Ditampilkan

Komponen yang tersedia:

- teks peringatan keamanan,
- field `PIN Lama`,
- field `PIN Baru`,
- field `Konfirmasi PIN Baru`,
- tombol `Update Keamanan`.

### Perilaku Sistem

- seluruh field menggunakan `obscureText: true`,
- tombol `Update Keamanan` hanya menjalankan `Navigator.pop(context)`,
- tidak ada pengecekan kecocokan PIN baru,
- tidak ada komunikasi ke backend atau local auth store.

### Validasi

Belum ada validasi berikut:

- PIN lama wajib diisi,
- panjang minimum PIN,
- PIN baru dan konfirmasi harus sama,
- snackbar atau dialog hasil update.

### 5.8. Bantuan Pengguna

### Tujuan

Halaman ini menampilkan entry point bantuan pengguna dan FAQ sederhana.

### Informasi yang Ditampilkan

Elemen UI yang tersedia:

- banner `Butuh Bantuan?`,
- teks `Tim support kami siap membantu 24/7`,
- tombol `Chat WhatsApp`,
- section `FAQ`,
- daftar FAQ:
  - `Cara menghubungkan printer?`
  - `Bagaimana cara refund transaksi?`
  - `Lupa PIN akses?`
  - `Cara export laporan ke Excel?`

### Perilaku Sistem

- tombol `Chat WhatsApp` belum memiliki aksi,
- seluruh item FAQ belum memiliki aksi,
- belum ada route detail FAQ atau integrasi ke WhatsApp/link eksternal.

### 5.9. Keluar Aplikasi

### Status Implementasi

Item `Keluar Aplikasi` sudah tampil di halaman utama `Setting`, tetapi saat ini:

- belum ada dialog konfirmasi,
- belum ada penghapusan token,
- belum ada redirect ke halaman login,
- callback `onTap` masih kosong.

## 6. Layout Printout

Pada implementasi modul `setting` saat ini, belum ada layout printout yang benar-benar dibentuk atau dikirim ke printer dari source code fitur ini.

Halaman `Printer & Struk` memang memiliki:

- tombol `Test Print`,
- toggle `Auto Print Struk`,
- toggle `Cetak Logo Toko`,
- dropdown `Lebar Kertas`.

Namun saat ini belum ada:

- generator print thermal,
- template struk,
- byte command printer,
- integrasi printer Bluetooth,
- hasil cetak `Test Print`,
- layout printout untuk tutup kasir atau laporan lain dari modul `setting`.

## 7. Ketergantungan Data dan Integrasi

Fitur pada modul `setting` saat ini bergantung pada:

### Navigasi

- `GoRouter`
- `context.push(...)`
- `context.pop()`

### Shared UI/Theme

- `AppColors` dari package `core`
- komponen `SettingItem`

### Asset/Data Eksternal

- `NetworkImage` ke `picsum.photos` untuk avatar dummy

### Yang Belum Dipakai

Modul ini saat ini belum menggunakan:

- endpoint API,
- repository,
- provider atau viewmodel khusus `setting`,
- database lokal,
- `SharedPreferences`,
- plugin Bluetooth,
- plugin printer,
- layanan autentikasi.

## 8. Kontrak Request Dan Response

Saat ini modul `setting` belum memiliki implementasi HTTP konkret. Namun, source code sudah memiliki kontrak repository dan remote abstract berikut:

- `getSettingConfig()`
- `updateStoreInfo(StoreInfoEntity storeInfo)`
- `updatePrinterSettings(PrinterSettingsEntity printerSettings)`
- `updatePaymentMethods(List<PaymentMethodEntity> paymentMethods)`
- `updateProfileSettings(ProfileSettingsEntity profileSettings)`
- `updateNotificationPreferences(NotificationPreferencesEntity notificationPreferences)`
- `updateSecuritySettings(SecuritySettingsEntity securitySettings)`

Karena itu, bagian ini mendokumentasikan **request/response contract yang diharapkan** untuk integrasi berikutnya.

Catatan penting:

- struktur di bawah ini adalah kontrak target,
- ini belum berarti endpoint HTTP sudah aktif di repo,
- nama path endpoint masih dapat disesuaikan saat implementasi backend nyata dibuat.

### 8.1. Ambil Setting Awal

### Tujuan

Mengambil seluruh konfigurasi awal untuk halaman `Setting`.

### Request

Contoh bentuk request:

```json
{}
```

Contoh headers yang diharapkan:

```json
{
  "Authorization": "Bearer <token>"
}
```

### Response

Contoh response yang diharapkan:

```json
{
  "data": {
    "store": {
      "store_name": "SB Coffee",
      "branch": "Jakarta Selatan",
      "address": "Jl. Sudirman No. 45, SCBD, Jakarta Selatan",
      "phone": "0812-3456-7890"
    },
    "printer": {
      "auto_print": true,
      "print_logo": true,
      "paper_width": "80mm",
      "devices": [
        {
          "name": "Epson TM-T82",
          "subtitle": "Terhubung",
          "is_connected": true
        }
      ]
    },
    "payment_methods": [
      {
        "id": 1,
        "name": "Tunai (Cash)",
        "is_active": true
      },
      {
        "id": 2,
        "name": "QRIS",
        "is_active": true
      }
    ],
    "profile": {
      "name": "Budi Santoso",
      "employee_id": "EMP-2023-001",
      "email": "budi@sbpos.com",
      "phone": "0812-9999-8888"
    },
    "notifications": {
      "push_notification": true,
      "transaction_sound": true,
      "stock_alert": true
    },
    "version_label": "SBPOS App v2"
  }
}
```

### 8.2. Update Informasi Toko

### Request

Payload request yang diharapkan:

```json
{
  "store_name": "SB Coffee Samarinda",
  "branch": "Samarinda Ulu",
  "address": "Jl. KH Wahid Hasyim No. 10",
  "phone": "0812-1111-2222"
}
```

### Response

Contoh response:

```json
{
  "data": {
    "store_name": "SB Coffee Samarinda",
    "branch": "Samarinda Ulu",
    "address": "Jl. KH Wahid Hasyim No. 10",
    "phone": "0812-1111-2222"
  },
  "message": "Informasi toko berhasil diperbarui"
}
```

### 8.3. Update Printer Settings

### Request

Payload request yang diharapkan:

```json
{
  "auto_print": true,
  "print_logo": false,
  "paper_width": "58mm",
  "devices": [
    {
      "name": "Epson TM-T82",
      "subtitle": "Terhubung",
      "is_connected": true
    }
  ]
}
```

### Response

Contoh response:

```json
{
  "data": {
    "auto_print": true,
    "print_logo": false,
    "paper_width": "58mm",
    "devices": [
      {
        "name": "Epson TM-T82",
        "subtitle": "Terhubung",
        "is_connected": true
      }
    ]
  },
  "message": "Pengaturan printer berhasil diperbarui"
}
```

### 8.4. Update Metode Pembayaran

### Request

Payload request yang diharapkan:

```json
{
  "payment_methods": [
    {
      "id": 1,
      "name": "Tunai (Cash)",
      "is_active": true
    },
    {
      "id": 5,
      "name": "Transfer Bank",
      "is_active": true
    }
  ]
}
```

### Response

Contoh response:

```json
{
  "data": [
    {
      "id": 1,
      "name": "Tunai (Cash)",
      "is_active": true
    },
    {
      "id": 5,
      "name": "Transfer Bank",
      "is_active": true
    }
  ],
  "message": "Metode pembayaran berhasil diperbarui"
}
```

### 8.5. Update Profil Pengguna

### Request

Payload request yang diharapkan:

```json
{
  "name": "Kasir Baru",
  "employee_id": "EMP-2023-001",
  "email": "kasir.baru@sbpos.com",
  "phone": "0812-0000-0000"
}
```

### Response

Contoh response:

```json
{
  "data": {
    "name": "Kasir Baru",
    "employee_id": "EMP-2023-001",
    "email": "kasir.baru@sbpos.com",
    "phone": "0812-0000-0000"
  },
  "message": "Profil berhasil diperbarui"
}
```

### 8.6. Update Preferensi Notifikasi

### Request

Payload request yang diharapkan:

```json
{
  "push_notification": true,
  "transaction_sound": false,
  "stock_alert": true
}
```

### Response

Contoh response:

```json
{
  "data": {
    "push_notification": true,
    "transaction_sound": false,
    "stock_alert": true
  },
  "message": "Preferensi notifikasi berhasil diperbarui"
}
```

### 8.7. Update Keamanan

### Request

Payload request yang diharapkan:

```json
{
  "old_pin": "123456",
  "new_pin": "654321",
  "confirm_pin": "654321"
}
```

### Response

Contoh response sukses:

```json
{
  "data": true,
  "message": "Pengaturan keamanan berhasil diperbarui"
}
```

Contoh response gagal validasi:

```json
{
  "data": false,
  "message": "PIN baru dan konfirmasi PIN harus sama"
}
```

## 9. Catatan Operasional

Berikut hal penting yang perlu dipahami dari implementasi saat ini:

1. Menu `Setting` sudah bisa dinavigasikan dari dashboard dan seluruh sub-screen utama dapat dibuka.
2. Sebagian besar data yang tampil masih berupa data dummy atau hard-coded.
3. Sebagian besar aksi edit belum menghasilkan perubahan yang tersimpan.
4. `Save` pada halaman `Informasi Toko` dan `Update Keamanan` hanya menutup halaman.
5. `Simpan Profil`, `Ubah Logo`, `Putus`, `Test Print`, `Chat WhatsApp`, FAQ, dan `Keluar Aplikasi` belum memiliki aksi nyata.
6. Tidak ada mekanisme restore state saat aplikasi dibuka ulang.

## 10. Keterbatasan yang Terlihat dari Implementasi Saat Ini

- belum ada state management khusus untuk `setting`,
- belum ada integration test atau widget test yang merepresentasikan screen-screen `setting`,
- test yang ada di package ini masih boilerplate Flutter default,
- beberapa halaman hanya bersifat prototipe UI,
- belum ada validasi input,
- belum ada persistence,
- belum ada integrasi backend,
- belum ada integrasi hardware printer/Bluetooth.

## 11. Referensi Source Code

File utama yang menjadi acuan panduan ini:

- `features/setting/lib/presentation/screens/setting_screen.dart`
- `features/setting/lib/presentation/screens/store_screen.dart`
- `features/setting/lib/presentation/screens/printer_screen.dart`
- `features/setting/lib/presentation/screens/payment_screen.dart`
- `features/setting/lib/presentation/screens/profile_screen.dart`
- `features/setting/lib/presentation/screens/notification_setting_screen.dart`
- `features/setting/lib/presentation/screens/security_screen.dart`
- `features/setting/lib/presentation/screens/help_screen.dart`
- `features/setting/lib/presentation/component/setting_item.dart`
- `features/dashboard/lib/presentation/widgets/quick_menu.dart`
- `core/lib/utils/app_routes.dart`
- `lib/app_router.dart`

## 12. Penutup

Menu `Setting` di implementasi SB POS saat ini sudah memiliki struktur navigasi dan tampilan UI yang cukup lengkap, tetapi sebagian besar masih berada pada tahap presentational layer. Secara fungsi bisnis, modul ini belum setara dengan contoh operasional penuh seperti pengelolaan printer nyata, penyimpanan profil, pengaturan notifikasi persisten, atau logout aktif.

Dokumentasi ini sebaiknya diperbarui setiap kali ada perubahan pada:

- aksi tombol,
- validasi input,
- persistence data,
- integrasi API,
- integrasi Bluetooth atau printer,
- flow logout dan keamanan.
