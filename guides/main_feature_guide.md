# Panduan Fitur Utama SB POS (Non-Setting)

Dokumen ini memuat dokumentasi lengkap mengenai arsitektur fungsional, **Alur (Flow) Pengguna**, **Mekanisme Layar (UI/Form)**, **Logika Bisnis / Rumus**, serta struktur **Payload API** untuk seluruh fitur operasional utama pada aplikasi kasir (SB POS) di luar menu Setting.

Semua panggilan API (kecuali Login) menggunakan autentikasi *Bearer Token* di bagian *Header*.

---

## 1. Autentikasi & Sesi Pengguna

### A. Login Akun & Refresh Token
Mekanisme ini menjadi pintu gerbang akses awal pengguna ke dalam aplikasi kasir dan mekanisme pembaruan token akses di belakang layar saat sesi berakhir.

- **Alur / Flow Pengguna**:
  1. Pengguna membuka aplikasi dan disajikan dengan layar Login Halaman Awal (*Splash & Login Screen*).
  2. Pengguna memasukkan *Email* dan *Password*, kemudian menekan tombol "Login".
  3. Sistem memvalidasi secara lokal (wajib diisi & panjang password), kemudian memanggil API.
  4. Jika berhasil, sistem menyimpan Token JWT, nama pengguna, `role_id`, dan `warehouse_id`, lalu mengarahkan kasir ke halaman utama.

- **Field Input yang Dibutuhkan**:
  - `Email` (Teks) & `Password` (Teks tersensor dengan tombol *eye* untuk melihat)
- **Komponen / Field Tampilan (UI)**:
  - Form Input Email & Password.
  - Tombol aksi `Login`.
  - Tombol `Lupa Password?` (Memicu snackbar instruksi melapor ke Admin).
  - Informasi Versi Aplikasi di bawah logo (Contoh: `V 1.0.0 (1)`).
- **Logika Bisnis & Validasi**:
  - Terdapat mekanisme perlindungan UI berupa form validator `Validatorless.min(5, ...)` di mana panjang *password* minimum tidak boleh kurang dari 5 karakter angka/huruf.

- **Endpoint**: `POST /api/login` (atau `/api/refresh-token` u/ perpanjangan sesi).
- **Request Payload**:
  ```json
  {
    "email": "kasir@demo.com",
    "password": "kasirdemo"
  }
  ```
- **Response Payload**:
  ```json
  {
    "user": {
      "id": 1,
      "name": "Kasir Satu",
      "email": "kasir@demo.com",
      "role_id": 2,
      "warehouse_id": 1,
      "is_active": 1
    },
    "access_token": "eyJ0e...<jwt-access>",
    "refresh_token": "def50...<refresh-token>"
  }
  ```

---

## 2. Manajemen Shift (Buka Kasir)

Aktivitas wajib harian ketika kasir pertama kali memulai kerjanya, mengharuskan pencatatan modal uang (Initial Balance) fisik yang ada di laci.

### A. Cek Status & Buka Kasir (Open Cashier)
Sistem secara otomatis mengunci menu utama apabila kasir belum membukukan modal uang awal hari/shift ini ke sistem.

- **Alur / Flow Pengguna**:
  1. Setelah Login, sistem otomatis menjalankan pemanggilan ke `/api/shift/check`.
  2. Jika respon dari server mengidentifikasi belum ada "Buka Kasir" yang valid (mengembalikan flag false), aplikasi langsung memaksa rute pindah ke Tampilan **Buka Kasir**.
  3. Kasir wajib mengisikan nominal uang tunai sisaan laci (Modal Awal Shift) di layar tersebut.
  4. Setelah nominal diisi dan kasir memencet `Buka Kasir`, aplikasi mengirim request POST.
  5. Bila valid, laci dianggap terbuka dan kasir dikembalikan ke tampilan Beranda.

- **Field Input yang Dibutuhkan**:
  - `Saldo Kasir` (Nominal uang rupiah) - *Wajib diisi dengan Keyboard angka/Numpad bawaan*.
- **Komponen / Field Tampilan (UI)**:
  - Header berbunyi "Buka Kasir".
  - Label informatif: "Silahkan masukkan jumlah saldo di laci".
  - Nominal berformat mata uang (Contoh: `Rp 250.000`).
  - Tombol eksekusi hijau bertuliskan `Buka Kasir`.
- **Logika Bisnis (Validasi)**: Angka harus memiliki nominal minimum 0 (tanpa huruf/spesial karakter). Tidak diperkenankan bernilai format *null/NaN*.

- **Endpoint**: `GET /api/shift/check` & `POST /api/shift/open`
- **Request Payload (Buka Kasir)**:
  ```json
  {
    "initial_balance": 250000
  }
  ```
- **Response Payload**: *Boolean / Response pesan sukses*. Lanjut render halaman "Home".

### B. Sinkronisasi Stok Awal (Initial Ingredient Stock)
Saat dialog "Buka Kasir" muncul, sistem tidak hanya meminta modal uang, tetapi juga melakukan sinkronisasi data stok:
- **Pemuatan Data**: Sistem otomatis menarik data sisa stok bahan baku (*Ingredients*) dari penutupan shift sebelumnya.
- **Referensi Kasir**: Data stok ini ditampilkan sebagai informasi pembanding (Read-only) bagi kasir untuk memastikan kesiapan bahan baku sebelum mulai berjualan.
- **Endpoint**: `GET /api/shift/latest` (Mendapatkan data sisa stok terakhir).

### C. Pemulihan Data Kasir Terakhir (Latest Shift Transaction)
Mekanisme opsional yang memanggil data agregasi (*omset* / stok berjalan) dari transasksi yang sudah pernah dicatat dalam kurun waktu buka kasir hari itu.

- **Endpoint**: `GET /api/shift/latest`
- **Mekanisme**: Mengambil status transaksi termutakhir, utamanya digunakan untuk parameter pembanding saat hendak melakukan aksi krusial lain atau sebelum mencetak struk rangkuman tutup kasir cadangan.

---

## 3. Sinkronisasi Master Data Transaksi

Data statis yang otomatis ditarik dari backend ke frontend setelah kasir berhasil buka aplikasi, agar user bebas bertransaksi.

### A. Kategori Induk Menu (*Custom Categories*)
Identitas pengelompokkan utama yang dipakai user untuk berpindah tab jenis dagangan.

- **Alur / Flow Backend**: Saat layar Home Kasir dimuat, aplikasi meminta daftar klasifikasi dasar.
- **Komponen / Tampilan (UI)**: Disajikan sebagai header text penanda layout panel kasir (Contoh: "MAKANAN", "TAMBAHAN", "MINUMAN", dll).
- **Endpoint**: `GET /api/customCategories`
- **Response**: Array of object id dan title kategori (*Categories Model*).

### B. Pengambilan Menu / Produk
Mengakses semua entitas item di outlet saat ini.

- **Endpoint**: `GET /api/products`
- **Response**: Menampilkan array list yang berisikan rincian harga, gambar, stok, resep racikan, hingga bahan tambahan.

### C. Jenis Pesanan (Order Types)
Memanggil tipe order seperti "Makan di tempat" (Dine in) atau "Bawa Pulang" (Takeaway). Berfungsi merender Dropdown pilihan sebelum checkout.

- **Endpoint**: `GET /api/transaction/order-types`
- **Response**: List ID & Nama tipe pemesanan.

### D. Pembayaran Ojek Online (Payment Apps)
Memanggil jenis pembayaran dari pihak ketiga jika ada komisi/fee transaksi (GoFood / ShopeeFood).

- **Endpoint & Payload Terkait**:
  - `GET /api/ojol`: Konversi fee aplikasi ojek online, jika outlet mengaktifkan metode ini.

- **Kebijakan Perubahan Harga Berdasarkan Ojol (Bisnis Logik)**:
  Aplikasi ini memiliki mekanisme pintar berupa fungsi `_resolveProductPrice()` di mana harga jual (Price) per menu di grid akan **berubah secara real-time** bergantung pada apa yang dipilih user di filter "Pilih Jenis Ojol".
  1. Jika kasir memilih `GoFood` -> Aplikasi menimpa harga awal dengan `gofoodPrice` (Harga khusus Gofood) dari API Product.
  2. Jika memilih `GrabFood` -> Mengganti harga pakai `grabfoodPrice` (serta Grab Prioritas jika ada).
  3. Jika memilih `ShopeeFood` -> Mengganti harga pakai `shopeefoodPrice`.
  4. Bila jenis pesanan biasa (Dine-in/Takeaway) -> Kembali pakai bawaan normal perhitungan kolom `price`.
  *(Fitur mark-up harga / perhitungan markup berdasarkan multiplier persentase telah dinonaktifkan/hardcoded agar langsung merujuk pada nilai absolut dari respon API database)*.

---

## 4. Proses Transaksi Kasir (Keranjang & Pembayaran)

Fitur inti point of sales, di mana pengguna meracik pesanan pembeli pada POS.

### A. Tambah Pesanan & Validasi QTY
- **Alur / Flow Pengguna**:
  1. Kasir mengetuk produk/menu di dalam grid layar.
  2. Sebuah modal Popup terbuka, meminta kasir mengisi jumlah tagihan (Qty) via tombol ( - / + ).
  3. Kasir menekan `Tambahkan ke Keranjang`.
  4. Secara asinkronus (*background*), aplikasi memicu `/api/transaction/check-qty`. Jika bahan resep yang terkandung mencukupi untuk order tersebut, menu tersebut divisualisasikan pindah ke bilah kanan (Cart View). Bila gagal, muncul *snackbar error stok kurang*.

- **Field Input yang Dibutuhkan**:
  - `Jumlah Qty` (Angka)
  - `Catatan Pesanan` (Teks, missal: "Es nya dikit").

### B. Kasir Melunasi Pesanan (Checkout / Post Transaction)
- **Alur / Flow Pengguna**:
  1. Di bilah *Cart* sisi kanan, user memeriksa rincian Item, memilih `Order Type` (Dine in/Takeaway), lalu menekan tombol hijau `Lanjutkan Pembayaran`.
  2. Akan terbuka rincian form final `Pembayaran`:
     - Kasir memilih Metode Pelunasan (Tunai, EDC/QRIS, atau Kasbon/Split).
     - Bila Tunai, kasir memilih tombol pintas uang pas (Uang Pas, Uang 50.000, atau nominal bebas).
  3. Setelah input nominal, tekan tombol Submit / Cetak, maka system mengirim data lengkap tagihan (`checkout/post transaction`).
  4. Aplikasi merender popup "Transaksi Berhasil Dicatat" dan memicu instruksi *Send Bytes to Bluetooth Thermal Printer* agar alat mencetak struk secara riil.

- **Field Input yang Dibutuhkan**:
  - `Nama Pelanggan` (Optional).
  - `Tipe Pesanan` (Dropdown).
  - `Tipe Pembayaran` (Tombol Pilihan Cash / QRIS / Apps).
  - `Uang Diterima / Cash Input` (Nominal rupiah).
- **Komponen / Field Tampilan (UI) Hasil**:
  - Subtotal per item, Total nilai belanja, Total Kembalian.
  - **Pintasan Nominal Tunai (Payment Shortcuts)**: Pada layar pembayaran tunai, tersedia tombol cepat untuk nominal (Rp 10.000, 20.000, 50.000, 100.000) dan tombol **"Uang Pas"** untuk mempercepat proses input uang tunai tanpa mengetik manual.
  - Opsi *Split Payment* bagi bayar separuh tunai separuh transfer (Bila fitur aktif).

- **Rumus & Logika Bisnis Belanja (POS Engine)**:
  - **Subtotal Produk**: Rumus `subtotal = jumlah(qtyBuy) * harga produk (price)`. Terus diupdate selama produk ditambahkan / diedit dari cart.
  - **Total Tagihan Bersih (paid_amount/TotalAmount)**: Secara terpusat mengakumulasi/menjumlah seluruh *subtotal* dari komponen *List Item Grid* (tanpa ditambah fee ojol karena fee ojol sudah dimapping/dimark-up di depan).
  - **Uang Kembali / Change Money**: Rumusnya cukup ketat `Kembalian = Uang Diterima (Dari Numpad Kasir) - Total Tagihan`. Jika uang diterima (cash input) *Kurang Dari* Total Tagihan, maka tombol checkout/bayar harus dideaktivasi oleh validator, di luar metode kasbon/split.

- **Endpoint & Route Kategori Transaksi**:
  Sistem memecah route api berdasarkan kategori ordernya.
  - Rute **Offline/Normal**: `POST /api/transaction` (Tamu order langsung di kedai).
  - Rute **Online/Ojol Apps**: `POST /api/transaction/online` (Bila kasir mentrigger parameter *Category Order: ONLINE* di layar).

- **Request Payload (Gambaran Contoh)**:
  ```json
  {
    "customer": "Budi",
    "order_type_id": 1,
    "payment_method": "cash",
    "sub_total": 45000,
    "total": 45000,
    "cash": 100000,
    "change": 55000,
    "items": [
      {
        "product_id": 10,
        "qty": 2,
        "price": 22500,
        "total_price": 45000,
        "note": "Jangan terlalu manis"
      }
    ]
  }
  ```

---

## 5. Manajemen Pesanan Offline / Gantung (Not-Paid)

Biasa digunakan dalam pola "Pesan dulu, bayar saat pulang" atau "Kasbon pelanggan tetap".

### A. Melacak Daftar Not-Paid
- **Alur Pengguna**: Saat Kasir mengklik Tab `Pesanan Offline` (atau tombol "Daftar Tunggakan") di layar Utama, sistem menarik data tagihan yang mengambang.
- **Tampilan (UI)**: Muncul daftar berbentuk kartu (List View) menampilkan Nomor Order/Meja, Nama Pelanggan, Waktu Order, Tipe Pesanan, dan Estimasi Harga. Terdapat tombol Aksi pada setiap struk: **Edit** dan **Batalkan**.
- **Endpoint**: `GET /api/transaction/not-paid`

### B. Otorisasi Pembatalan Tagihan (Cancel Request & OTP)
Kasir tidak bisa sewenang-wenang menghapus pesanan yang sudah berjalan/dibuatkan di dapur demi mencegah Fraud/Fraudulent Cancellation.

- **Alur / Flow Pengguna**:
  1. Kasir menekan tombol `Batalkan Pesanan` pada item list order pending.
  2. Akan terbuka Dialog wajib memasukkan "Alasan Batal".
  3. Ketika disubmit, aplikasi akan nembak API `/cancel-request-all` atau per-item yang mana Backend mengirimkan pesan Whatsapp *OTP* ke pimpinan.
  4. Aplikasi menampilkan layar tunggu agar Kasir mengisikan kode OTP angka (6-digit) yang didapat dari Manajernya.
  5. Jika valid, eksekusi hapus final dikirim lewat route PUT `/cancel-all` atau `/cancel/{id}`.
  6. Menu hilang dari layar order offline.

- **Rumus Keamanan / Logika Reverse Stock**:
  - Jika pembatalan berhasil, backend secara otomatis menjalankan prosedur **Reverse Entry Stock** alias *Refund Inventory* yang menyuntikkan dan mendeposit kembali (menambahkan) besaran stok mentah (`qty sum`) persis seperti awal mula keadaan sebelum transaksi dibuat (agar tidak terjadi penyusutan palsu karena pelanggan kabur).

- **Field Input yang Dibutuhkan**:
  - `Alasan Batal` (Tulisan panjang), misal "Cust berubah pikiran".
  - `OTP` (Form Wajib 6 angka PIN Supervisor).
- **Endpoint**:
  - Request OTP Supervisor: `POST /api/transaction/cancel-request` (Mengirim ID order & alasan).
  - Submit Final / Void: `PUT /api/transaction/{id}/cancel` (Submit OTP = `{"otp": 123456}`).

### C. Melanjutkan/Edit Tagihan (Check Edit Order)
Kasir bisa memanggil kembali *Order Pending* masuk kembali ke dalam keranjang untuk ditambah sausnya, atau diselesaikan pembayarannya bila tamu pulang.

- **Alur / Flow Pengguna**:
  1. Pengguna menekan tombol `Edit` (icon Pencil) pada item di tab Order Offline.
  2. Sistem nembak `GET /api/edit-order/check`.
  3. Jika backend mendeteksi tagihan tersebut tidak terkunci (masih berhak dimodifikasi shift saat ini/kasir tidak bentrok), pesanan dibongkar masuk lagi ke antarmuka Home Kasir -> Sisi Keranjang (Cart) persis keadaannya seperti awal mula sebelum dipending.
  4. Kasir kemudian bebas menginput pembayaran (lanjut ke Proses Check Out #4B)

---

## 6. Service / Health Check API

Fungsi administrasi diam-diam (Silent Mechanism) di belakang layar untuk menjaga status lisensi terminal POS.

### A. Cek Kelayakan Operasional Aplikasi
- **Endpoint**: `GET /api/service/check`
- **Mekanisme & Flow**:
  - Tidak ada UI pemicu langsung oleh user / tombol mandiri. Dipanggil di root halaman aplikasi kasir setiap beberapa waktu.
  - Jika `GET /api/service/check` bernilai False / Lisensi tidak diizinkan (karena nunggak perpanjangan bill dsb), maka layar kasir akan disusupi / ditutupi oleh Popup penuh bertuliskan instruksi pembayaran iuran server bulanan agar POS bisa diakses kembali.

### B. Validasi Masa Aktif Berlangganan (Subscription)
- **Endpoint**: `GET /api/subscription/status`
- **Mekanisme**: Sistem melakukan verifikasi aktifitas lisensi melalui API ini untuk memastikan perangkat masih dalam periode sewa/berlangganan yang sah. Jika masa tenggat telah lewat (*Expired Subscription*), akun klien akan di-blok atau dilimited fiturnya secara otomatis oleh sistem.

---

## 7. Engine Printer Thermal Bluetooth & Hardware

Bagian ini memaparkan integrasi *hardware* pencetak struk yang berjalan secara *Local Bluetooth* dari kasir tanpa mengandalkan internet.

### A. Mekanisme & Library Dasar
Sistem SB POS merender teks struk menjadi sekumpulan `List<int>` (Bytes) kode perintah ESC/POS. Dua core library yang dipakai:
1. `print_bluetooth_thermal` -> Digunakan untuk scanning device, connect by MAC Address, cek baterai, dan pengiriman byte (perintah `writeBytes()`).
2. `esc_pos_utils_plus` -> Digunakan sebagai *Generator* format layout receipt kertas 58mm (`PaperSize.mm58`), seperti format huruf tebal, spasi tinggi, dan susunan tabel bill.

### B. Proses Binding / Pairing Device
Penyimpanan *state* koneksi berada terpusat pada file pengaturan kasir (`setting_controller.dart`).
- **Pencarian**: Aplikasi mendeteksi device (*Paired Bluetooths*) secara natif.
- **Koneksi**: Setelah kasir mengklik perangkat printer, aplikasi memanggil `PrintBluetoothThermal.connect(macPrinterAddress)`.
- **Auto-Connect**: Karena adanya fungsi `connectToSavedPrinter()`, aplikasi akan otomatis mencoba *re-connect* ke printer lama setiap kali aplikasi di-restart tanpa perlu pairing ulang.

### C. Klasifikasi File Cetak (Format Struk)
Sistem memiliki berbagai spesifikasi format file cetak yang terletak di folder rute `lib/features/home/kasir/printout/`:
1. `PrintUser`: Format reguler struk kembalian untuk konsumen di kedai/dine in.
2. `PrintOnline`: Format struk pesanan dari Ekspedisi/Ojol Apps, di mana nomor referensi/PIN dari aplikasi ojol tertera lebih jelas.
3. `PrintKitchen`: Format cetak terpisah ("Chit") untuk dikirim ke dapur. Format ini tidak menampilkan harga rupiah, melainkan murni rincian pesanan (*Qty* & Notes pesanan) yang perlu disiapkan koki.
4. `PrintCloseCashier`: Format cetak shift harian. Menampilkan angka agregasi penjualan (Tunai, QRIS, total kasbon) untuk disertorkan kepada owner/manajer tutup toko.

### D. Aturan ESC/POS dan Hardcode Header
Saat mendesain format tiket *receipt*, ada beberapa penyesuaian fungsional:
- **Header Toko Fix**: Parameter seperti nama Toko pada struk ("SB POS") saat ini dibuat secara **hardcoded** / terpaten dalam byte array generator layout.
- **Mekanisme *Dual Printing* (Pelanggan & Dapur)**: Setiap transaksi sukses otomatis memicu dua perintah cetak: satu struk lengkap untuk pelanggan dan satu struk ringkas (*Kitchen Chit*) untuk bagian dapur.
- **Status Hardware (Monitoring & Auto-Reconnect)**:
  - **Level Baterai**: Aplikasi mendeteksi level baterai printer Bluetooth agar kasir waspada saat daya tinggal sedikit.
  - **Auto-Reconnect**: Sistem menyimpan Mac Address printer secara permanen di preferensi perangkat agar aplikasi otomatis menyambung kembali setiap kali printer menyala tanpa perlu pairing ulang.
  - **Uji Coba Hardware (Test Print / `testTicket`)**: Tersedia tombol "Test Print" yang mengirimkan byte array khusus untuk memicu printer thermal mencetak teks verifikasi kesiapan pemanas (*heat element*) printer sebelum operasional dimulai.

---

## 8. Mode *Self-Service* (Kiosk Mandiri)

Sistem mendukung implementasi mode layar sentuh untuk pelanggan yang memesan langsung tanpa dilayani operator/kasir di konter.

### A. Pengaktifan Flag Logic
Pengendali utama adalah parameter **boolean** `isSelfService` yang dibawa ke dalam *constructor* `HomeScreen` dan di inisialisasi pada status awal `HomeController`. Parameter penentu jalannya UI ini bertugas mengisolasi *flow* rumit agar konsumen tidak kebingungan.

### B. Perubahan Alur Belanja (UI / UX Modals)
Ketika `isSelfService` diset ke `TRUE`, ada 2 perbedaan fungsi utama yang paling menonjol dibandingkan mode kasir normal:
1. **Penghilangan Fitur Eksternal (*Ojol/Payment App*)**: Label filter opsi kanan disederhanakan murni menjadi statis "Pilih Jenis Pesanan". Pilihan jenis Ojek Online (GoFood, Grab, Shopee) dihilangkan agar konsumen tidak menyalahgunakan override harga merchant.
2. **Potong Jalan Form Checkout**: Saat pembeli menekan tombol hijau *Pesan Makan* pada Bottom-Bar, mesin mem-*bypass* tampilan `dialogPesanNotSelfService` (Lay Out Periksa Pesanan Klasik). Sebaliknya, pembeli langsung dihadapkan pada antarmuka *CartCustomerSheet* / *Payment Gateway* untuk metode pelunasan yang disimplifikasi, karena pembeli langsung membayarnya saat itu juga sebelum struk keluar.

---

## 9. Hak Akses Peran Pengguna (*Role-Based Permissions*)

Meskipun terlihat kasir bisa mengklik hampir segala sesuatu di modul layar, ada arsitektur keamanan (*Role-Based*) yang diterapkan bertingkat dari sisi backend.

### A. Pemetaan Identitas Kasir
Berdasarkan referensi identitas pengguna, sistem mendata minimal atribut `role_id`, `warehouse_id`, dan `user_id` yang terikat pada login operator tertentu. Atribut yang mendefinisikan operator ini digunakan oleh *Backend API* secara ketat untuk men-validate relasi transaksi tiap meja dan order type.

### B. Otorisasi Supervisor (Bypass Restrictions)
Di level Client (Flutter App), aplikasi SB POS dirancang untuk **tidak memblokir penuh secara paksa / menyembunyikan fungsi UI** bermodalkan `if (role_id != 1) { hide }` di *front-end*. Konsep keamanan dibangun dengan model **"Gatekeeping by Action"**. Contoh penerapan:
- Kasir diizinkan melihat semua tagihan pending.
- Kasir diperbolehkan membuka sub-menu penghapusan (*Cancel Request*).
- **Pemblokiran Murni**: Namun saat mengeksekusi klik final, API menahan rute proses (*Voiding/Cancel*) hingga sang kasir berhasil meyakini/meminta **Kode PIN/OTP 6-digit** ke Manajer atau Supervisor dari Whatsapp (di luar sistem POS layar).
- Konsep anti-fraud ini sangat kokoh, karena meminimalisir kemungkinan peretasan lokal Front-End Flutter (membongkar parameter state aplikasi lewat cache bypass). Tanpa verifikasi server, barang dan status billing di sistem tidak bisa dicurangi untuk dikembalikan ke kantong mandiri.

---

## 10. Sistem Antrian & Nomor Urut (Queue System)

SB POS menggunakan identitas unik berbasis urutan untuk memudahkan sinkronisasi antara kasir, pelanggan, dan bagian dapur.

### A. Mekanisme Nomor Antrian (`sequenceNumber`)
- **Sumber Data**: Setiap kali transaksi berhasil (`POST /api/transaction`), server mengembalikan field `sequence_number`.
- **Visualisasi**: Nomor ini dicetak dengan ukuran besar (Bold) di bagian paling atas struk konsumen dan struk dapur.
- **Tujuan**: Memudahkan Koki memanggil pelanggan atau mencocokan nampan makanan dengan struk yang dibawa pembeli tanpa harus membaca rincian menu secara detail.

---

## 11. Histori Transaksi & Cetak Ulang (Reprint)

Fitur untuk melihat kembali catatan penjualan yang sudah lewat dan mencetak ulang struk jika printer macet atau pelanggan meminta salinan.

### A. Filter & Pencarian Histori
- **Rute API**: `GET /api/transaction/history/offline` atau `.../history/online`.
- **Fungsi Search**: Kasir dapat mencari nota lama berdasarkan "Nomor Antrian" secara real-time di layar histori.
- **Warna Status**:
   - **Hijau**: Lunas (Sudah bayar).
   - **Kuning**: Pending (Masih gantung).
   - **Merah**: Batal (Void).

### B. Mekanisme Cetak Ulang (Reprint Logic)
Aplikasi menggunakan class generator khusus untuk reprint agar tidak terjadi duplikasi nomor antrian baru:
- `PrintHistoryOffline`: Generator struk penjualan lama.
- `PrintHistoryOfflineKitchen`: Generator struk dapur lama (untuk permintaan masak ulang).
Tombol **"Print Ulang"** akan memicu pengiriman ulang bytes ke printer bluetooth yang saat ini aktif/terhubung.

---

## 12. Mekanisme Aktivasi & Lisensi Perangkat

Sebelum aplikasi bisa digunakan untuk transaksi, perangkat (Tablet/HP) harus terverifikasi sebagai terminal resmi outlet tersebut.

### A. Kode Aktivasi & Digital PID
Aplikasi menggunakan sistem keamanan ganda untuk aktivasi:
1. **Activation Code**: Kode unik yang diberikan Admin kepada outlet untuk meregistrasi perangkat baru.
2. **Digital PID**: ID unik perangkat (Hardware ID) yang didaftarkan ke server agar satu akun kasir tidak bisa digunakan di banyak perangkat tanpa izin.
3. **Status Aktivasi**: Status ini tersimpan di sistem perangkat. Jika status ini hilang (Wipe data app), aplikasi akan kembali ke layar "Activation Required" sebelum bisa melakukan login.

---

---

## 13. Logika Harga Promosi & Diskon

Sistem SB POS mendukung skema perubahan harga otomatis berbasis periode untuk menu-menu tertentu.

### A. Prioritas Harga (Promotion Price)
Aplikasi melakukan pengecekan pada field `promotion` dan `promotionPrice` di setiap data produk:
- **Aktif**: Jika status promo aktif dan tanggal saat ini berada di antara `startingDate` dan `lastDate`, maka harga yang ditampilkan dan digunakan untuk transaksi adalah `promotionPrice`.
- **Tidak Aktif**: Jika status promo non-aktif atau masa berlaku lewat, maka sistem kembali menggunakan harga reguler (`price`).

---

## 14. Mekanisme Perpajakan (Taxation)

Perhitungan pajak pada SB POS bersifat fleksibel mengikuti aturan outlet yang tersimpan di field `taxId` dan `taxMethod`.

### A. Metode Pajak (Inclusive vs Exclusive)
- **Inclusive (Termasuk Harga)**: Jika `taxMethod` diset sebagai *Inclusive*, maka harga menu yang tertera di grid sudah merupakan harga final. Sistem hanya akan memecah rincian nilai pajak di dalam struk tanpa menambah total tagihan.
- **Exclusive (Tambahan)**: Jika `taxMethod` diset sebagai *Exclusive*, maka sistem secara otomatis akan menambahkan persentase pajak di atas subtotal belanja pada layar konfirmasi pembayaran.

---

## 15. Peringatan Stok Rendah (Low Stock Alert)

Fitur proteksi dini agar operasional kedai tidak terhenti akibat kehabisan bahan baku secara mendadak.

### A. Ambang Batas (`alertQuantity`)
Setiap produk memiliki parameter `alertQuantity` (Ambang Batas Minimun):
- **Indikator Visual**: Saat stok fisik (`qty`) menyentuh atau berada di bawah angka `alertQuantity`, sistem akan memberikan penanda visual pada kartu menu di layar kasir (biasanya berupa teks sisa stok berwarna merah atau label "Stok Menipis").
- **Tujuan**: Memberikan sinyal kepada kasir untuk segera melakukan *Stock Entry* atau melaporkan kebutuhan belanja bahan kepada tim dapur/logistik.

---

## 16. Produk Berbasis Resep & Komposisi (Ingredients)

Tidak semua menu memiliki stok unit mandiri; beberapa menu bergantung pada ketersediaan bahan mentah.

### A. Keterkaitan Bahan (`isHaveIngredients`)
- **Logika Hubungan**: Untuk produk dengan flag `isHaveIngredients: TRUE`, stok menu tersebut bersifat **Virtual**.
- **Validasi Transaksi**: Saat kasir mengetuk menu, sistem mengecek stok bahan-bahan penyusunnya (misal: berat tepung, jumlah telur, dll) melalui API `/api/transaction/check-qty`.
- **Auto-Sold Out**: Jika salah satu bahan habis, maka menu utama otomatis akan dianggap "Stok Habis" dan tidak bisa dipesan, meskipun menu dasarnya sendiri terlihat tersedia.

---

---

---

## 17. Pengelolaan Pengeluaran (Expense Management)

Fitur untuk mencatat biaya operasional outlet (Kas Keluar) agar saldo kasir tetap akurat saat penutupan shift.

### A. Alur Pencatatan Kas Keluar
1. **Pemicu**: Kasir/Admin membuka menu "Kelola Pengeluaran".
2. **Form Input**:
   - `Kategori Pengeluaran`: Dropdown kategori (misal: Gas, Listrik, Parkir, Bahan Baku Dadakan).
   - `Jumlah (Qty)`: Kuantitas barang yang dibeli (opsional).
   - `Total Harga`: Nominal uang yang dikeluarkan.
   - `Catatan (Notes)`: Keterangan tambahan (misal: "Beli galon 2 buah").
3. **Efek Akuntansi**: Pengeluaran ini akan mengurangi nilai `Total Cash` yang seharusnya ada di laci saat proses **Print Close Cashier**.
4. **Endpoint**: `GET /api/expense` (Riwayat) & `POST /api/expense/add` (Simpan baru).

---

## 18. Manajemen Stok Masuk (Stock Entry)

Sistem untuk menambah persediaan bahan mentah (Ingredients) yang baru datang dari supplier.

### A. Alur Update Stok Virtual
1. **Pemicu**: User membuka menu "Kelola Stok".
2. **Proses Input**:
   - User memilih jenis bahan (`ingredient_id`) dari daftar.
   - Memasukkan `Qty` (Jumlah masuk) dan `Price` (Harga beli per unit).
   - Menambahkan catatan atau referensi nota supplier jika perlu.
3. **Dampak Sistem**: Stok ini akan langsung menambah saldo stok fisik yang digunakan oleh fitur `check-qty` di layar kasir. Jika stok masuk dicatat, menu yang tadinya *Sold Out* (habis) akan otomatis tersedia kembali.
4. **Endpoint**: `GET /api/stock-history` & `POST /api/stocks/add`.

---

---

## 19. Prosedur Tutup Kasir (Manual Reconciliation)

Proses krusial di akhir shift untuk memastikan kecocokan antara stok fisik, uang di laci, dan laporan sistem.

### A. Alur Validasi & Input
1. **Cek Transaksi Pending**: Sistem melakukan validasi otomatis. Jika masih ada pesanan "Not-Paid", kasir dilarang melakukan tutup kasir hingga pesanan tersebut dilunasi atau dibatalkan (Void).
2. **Stock Opname Harian**: Kasir wajib menginput **Sisa Stok Fisik** untuk seluruh bahan baku (*Ingredients*). Ini berfungsi untuk mendeteksi penyusutan bahan yang tidak wajar.
3. **Penghitungan Uang Fisik (*Cash Counting*)**: Kasir menghitung uang tunai yang ada di dalam laci dan menginputnya ke sistem (`cash_in_drawer`).
4. **Finalisasi & Laporan Audit**:
   - **Audit Shift Berurutan**: Sistem memvalidasi nomor shift (`shiftNumber`) dari server untuk memastikan alur pelaporan tutup kasir dilakukan sesuai urutan kronologis yang benar di database.
   - **Analisis Selisih Kas (Variance Analysis)**: Sistem menghitung selisih antara uang fisik vs sistem secara otomatis. Aplikasi memberikan *early-warning* kepada kasir jika ditemukan selisih sebelum data final diposting ke cloud.
   - **Pemisahan Omzet per Channel**: Laporan akhir memecah omset per platform (GoFood, Grab, Shopee, QRIS, dan Tunai) untuk akurasi rekonsiliasi.
   - Setelah data dikirim, status kasir berubah menjadi "Closed", sesi berakhir, dan aplikasi mencetak struk **PrintCloseCashier**.

---

## 20. Manajemen Keranjang Belanja (Cart Interactivity)

Mekanisme pengelolaan item yang sedang dipesan sebelum pembayaran final.

### A. Fitur Interaksi Cart
- **Update Qty Langsung**: Kasir dapat menambah (`+`) atau mengurangi (`-`) jumlah produk langsung dari bilah keranjang belanja.
- **Validasi Stok Otomatis**: Setiap penambahan Qty memicu fungsi asinkronus `checkQty` ke server. Jika stok (termasuk stok bahan baku) tidak mencukupi, sistem akan menolak penambahan tersebut.
- **Penghapusan Item**: Kasir dapat menghapus produk dari keranjang menggunakan ikon *Delete*, yang secara otomatis akan mengkalkulasi ulang total tagihan di layar.

---

## 21. Navigasi & Pencarian Menu (UI Logic)

Cara efisien bagi kasir untuk menemukan produk di tengah ratusan daftar menu.

### A. Debounce Search & Filter
- **Pencarian Pintar**: Kotak pencarian menu menggunakan logika **Debounce** sebelum menjalankan filter agar UI tetap ringan.
- **Navigasi Kategori**: Kasir dapat berpindah antar kategori melalui Tab Bar.
- **Logika Input Mata Uang Dinamis**: Seluruh kolom input uang (Bayar, Pengeluaran, Modal) dilengkapi *formatter* otomatis yang menambahkan simbol "Rp" dan titik ribuan secara *real-time* untuk mencegah kesalahan penulisan (*typo*).

---

## 22. Operasional Teknis & Startup Aplikasi

Bagian ini menjelaskan mekanisme "di balik layar" saat aplikasi pertama kali dijalankan oleh kasir untuk memastikan kesiapan perangkat.

### A. Konfigurasi Tampilan (Fixed Landscape)
Aplikasi SB POS dirancang khusus untuk penggunaan pada tablet dengan orientasi layar yang tetap:
- **Metode Penguncian**: Menggunakan `SystemChrome.setPreferredOrientations` dan konfigurasi native untuk mengunci aplikasi hanya pada mode mendatar (Landscape), menjaga tata letak grid produk tetap konsisten meski perangkat diputar secara fisik.
- **Rasional Desain**: Grid menu produk (4-5 kolom) dan bilah sisi keranjang belanja (sidebar) memerlukan ruang horizontal yang luas. Penguncian ini mencegah UI "pecah" atau elemen bertumpuk yang biasanya terjadi jika aplikasi dipaksa berjalan dalam mode Portrait.
- **Konsistensi Dialog**: Seluruh modal popup (seperti pembayaran dan detail pesanan) memiliki aspek rasio yang dioptimalkan untuk lebar layar landscape, memastikan tombol aksi tetap terlihat tanpa perlu banyak melakukan scrolling.

### B. Manajemen Izin Perangkat (Hardware Permissions)
Sistem melakukan audit keamanan dan perizinan secara proaktif di awal sesi:
- **Bluetooth & Bluetooth Connect**: Dibutuhkan untuk memindai (*scan*), memasangkan (*pair*), dan mengirimkan data biner struk ke printer thermal. Tanpa izin ini, aplikasi tidak dapat mendeteksi keberadaan printer di sekitar.
- **Location (Akses Lokasi)**: Merupakan syarat wajib dari sistem operasi Android (API 30 ke bawah) untuk melakukan pemindaian perangkat Bluetooth Low Energy (BLE). Aplikasi tidak merekam koordinat GPS user, namun izin ini teknis diperlukan untuk fungsi Bluetooth.
- **Permission Handler**: Aplikasi menggunakan library `permission_handler` untuk memicu dialog sistem secara berurutan. Jika user menolak izin krusial, aplikasi akan terus menampilkan peringatan atau mengarahkan user ke menu "Settings" perangkat karena fungsi kasir tidak akan berjalan normal tanpa izin tersebut.

### C. Pelaporan Error Real-Time (Firebase Crashlytics)
Aplikasi memantau kesehatan sistem selama 24 jam. Setiap terjadi *crash* (aplikasi menutup tiba-tiba) atau *error* pada logika asinkronus, sistem akan merekam jejak error tersebut dan mengirimkannya ke panel kontrol **Firebase Crashlytics**. Ini memudahkan tim pengembang untuk mendeteksi bug di outlet tertentu tanpa harus datang ke lokasi.

### D. Pemeriksaan Printer Otomatis (Startup Auto-Check)
Setiap kali aplikasi dibuka, sistem menjalankan fungsi `connectToPrinterAndPrint`. Fungsi ini secara otomatis mencoba menghubungi MAC Address printer terakhir yang tersimpan di memori. Jika gagal, aplikasi akan memunculkan snackbar peringatan di awal sehingga kasir bisa memperbaiki koneksi bluetooth sebelum mulai melayani antrean pelanggan.

### E. Mekanisme Pembaruan Otomatis (Upgrade Alert)
Aplikasi SB POS dilengkapi dengan fitur deteksi versi terbaru menggunakan `UpgradeAlert`:
- **Pengecekan Versi**: Sistem membandingkan versi internal dengan versi terbaru di server.
- **Paksa Update**: Jika ditemukan versi baru yang krusial, sistem akan meminta pengguna melakukan *update* ke versi terbaru.

### F. Keamanan Alur & Umpan Balik (UX Safety)
- **Proteksi Navigasi (PopScope)**: Pada layar krusial (Login, Buka/Tutup Kasir), sistem menonaktifkan tombol "Back" HP agar alur data tidak terputus secara tidak rasm.
- **Indikator Loading Overlay**: Penggunaan sistem kunci layar (*loading overlay*) saat proses API berlangsung untuk mencegah klik ganda (*anti-double click*) yang berpotensi menyebabkan duplikasi transaksi.

---

## 23. Logika Bisnis & Komunikasi API Lanjutan

Bagian ini merinci aspek teknis pemrosesan data dan komunikasi server yang memastikan integritas sistem SB POS.

### A. Jaringan & Ketahanan API (*Network Resilience*)
1.  **Standar Timeout Transaksi**: Sistem menerapkan *timeout* global selama 60 detik untuk seluruh permintaan API. Hal ini memastikan aplikasi tidak "menggantung" tanpa batas saat jaringan tidak stabil dan memberikan sinyal kegagalan yang jelas ke user.
2.  **Taksonomi Error HTTP**: Aplikasi melakukan pemetaan respon status code (400, 422, 500) secara seragam. Setiap respon error dari server akan diterjemahkan menjadi pesan *Snackbar* yang manusiawi, memudahkan kasir melakukan diagnosa mandiri (misal: "Stok Tidak Cukup" atau "Server Sibuk").
3.  **Restorasi Sesi Otomatis (*Recursive Callback*)**: Jika aplikasi menerima error 401 (*Unauthorized*), sistem secara otomatis menjalankan fungsi `serviceGetRefreshToken`. Jika sukses, aplikasi akan mengulangi permintaan API terakhir secara otomatis tanpa interferensi user.
4.  **Protokol Keamanan Keluar (*Forced Log-out*)**: Jika sesi gagal diperbarui (error 403), aplikasi secara paksa mengarahkan user kembali ke layar Login dan menghapus status sesi aktif demi keamanan data outlet.
5.  **Audit Kelayakan Tutup Kasir (*Closable Check*)**: Tombol Tutup Kasir diproteksi oleh fungsi `closable`. Jika API mengembalikan status `FALSE` (karena ada pesanan yang belum dilunasi), layar penutupan akan terkunci untuk mencegah laporan keuangan yang menggantung.

### B. Kalkulasi & Parameter Finansial
6.  **Surcharge Pembayaran (*Extra Price*)**: Sistem mendukung parameter `extra_price` pada tipe pembayaran tertentu (misal: biaya admin QRIS). Biaya ini ditambahkan otomatis ke total tagihan tanpa merubah harga dasar produk.
7.  **Diskon/Biaya Persentase**: Selain nominal tetap, sistem mendukung field `percent` untuk kalkulasi biaya layanan atau diskon yang bergantung pada total nilai transaksi.
8.  **Konsistensi Fiskal (*Money2 Standard*)**: Seluruh perhitungan aritmatika uang menggunakan library `Money2` dengan format `IDR`. Pengaturan `decimalDigits: 0` memastikan tampilan Rupiah yang bersih tanpa angka desimal di belakang koma, menjaga akurasi hingga digit terakhir.
9.  **Logika Sequence Number Antrean**: Nomor antrean panggil (Sequence) di-generate secara terpusat oleh server untuk setiap *Warehouse*, memastikan tidak ada nomor ganda meskipun outlet menggunakan beberapa unit tablet kasir sekaligus.
10. **Mapping Pajak Inklusif/Eksklusif**: Sistem mampu membedakan perhitungan pajak yang sudah termasuk di dalam harga (*Inclusive*) atau ditambahkan di akhir (*Exclusive*) berdasarkan parameter dari backend.

---

## 24. UX, Perangkat Keras & Integrasi Sistem

Detail integrasi antarmuka dan interaksi perangkat keras yang mendukung efisiensi kerja kasir.

### A. Interaksi Antarmuka & UX
11. **Visual Feedback (*Loader Overlay*)**: Implementasi `loaderOverlay` secara global mengunci seluruh layar saat proses transaksi sedang dikirim. Fitur ini berfungsi sebagai *Anti-Double Click* untuk mencegah pengiriman data ganda yang tidak sengaja.
12. **Algoritma Pencarian Efisien (*Debounce*)**: Fitur pencarian produk menggunakan pengatur waktu (timer) internal. Filter produk hanya akan dijalankan milidetik setelah kasir berhenti mengetik, sehingga performa perangkat tetap stabil meski memiliki ribuan menu.
13. **Proteksi Tombol Navigasi Fisik**: Penggunaan `PopScope` pada layar krusial (Login, Penutupan) memastikan alur operasional tidak terputus akibat penekanan tombol "Back" atau gestur navigasi HP yang tidak disengaja.
14. **Lokalitas Bahasa (Hardcoded ID)**: String antarmuka menggunakan bahasa Indonesia secara langsung (*Hardcoded*) untuk mengejar performa render maksimal tanpa latensi pemrosesan library lokalisasi pihak ketiga.
15. **Manajemen Versi App (*Self-Audit*)**: Metadata aplikasi (Version & Build Number) ditampilkan secara dinamis di *footer* sidebar. Informasi ini diambil langsung dari `PackageInfo` untuk memudahkan audit versi saat proses pemeliharaan.

### B. Integrasi Perangkat & Cloud
16. **Mekanisme *Dual Printing* Tersegmentasi**: Logika pemisah struk membedakan data yang dikirim ke `PrintUser` (fokus pada nominal dan kembalian) dan `PrintKitchen` (fokus pada menu dan catatan pesanan) dalam satu pemicu tombol.
17. **Retensi Identitas Hardware**: Sistem menyimpan MAC Address printer secara persisten agar fungsi `Startup Auto-Check` dapat langsung melakukan *Handshake* dengan perangkat saat aplikasi baru saja dinyalakan.
18. **Sinkronisasi Token Firebase (FCM)**: Setiap kali user melakukan login, sistem memperbarui `Registration Token` Firebase. Ini memungkinkan server mengirimkan notifikasi status atau pembaruan konfigurasi secara *real-time* ke tablet kasir.
19. **Fleksibilitas Satuan Stok (*UoM Handling*)**: Modul stok masuk mendukung berbagai satuan unit (Gram, Mili, Pcs) yang dikonversi secara otomatis saat proses *Stock Entry* untuk sinkronisasi dengan pemakaian menu.
20. **Monitoring Kesalahan Global (*Crashlytics*)**: Integrasi Firebase Crashlytics secara pasif merekam seluruh *unhandled exception* (galat yang tidak tertangkap). Data ini dikirim ke server pengembang beserta detail *stack trace* untuk proses perbaikan bug jarak jauh tanpa mengganggu operasional outlet.

---

## 25. Keamanan Perangkat, Lisensi & Audit Sistem

Detail tambahan mengenai perlindungan data dan mekanisme lisensi pada setiap unit tablet POS.

### A. Lisensi & Identitas Perangkat
1. **Identifikasi Digital PID**: Sistem menyimpan `DIGITAL_PID` sebagai tanda pengenal unik perangkat keras. Hal ini memastikan satu lisensi terikat pada satu spesifikasi tablet tertentu untuk mencegah duplikasi akun di banyak perangkat.
2. **Manajemen Outlet Default (*Warehouse Persistence*)**: Aplikasi memiliki fitur untuk mengingat outlet terakhir tempat kasir bertugas (`defaultWarehouse`). Kasir tidak perlu memilih ulang lokasi setiap kali aplikasi dijalankan kembali.
3. **Logika Aktivasi Ganda (*New Activation Code*)**: Mendukung penggunaan `activationCodeCacheNew` yang memungkinkan transisi kode lisensi lama ke baru tanpa perlu menghapus data aplikasi (*re-install*).
4. **Resiliensi Sesi (*Refresh Token Cycle*)**: Implementasi logika `tokenRefresh` yang secara transparan memperbarui akses kasir sebelum masa aktif token utama habis, menjaga kelancaran transaksi tanpa interupsi login ulang.

### B. Audit & Proteksi Operasional
5. **Proteksi *Double-Back* Dialog**: Seluruh jendela dialog penting (seperti formulir pembayaran) menggunakan `PopScope` untuk menonaktifkan tombol kembali Android, mencegah kasir menutup transaksi secara tidak sengaja.
6. **Audit Kesalahan Data (*SomethingDataException*)**: Perekaman khusus pada galat tingkat data ke dalam konsol pengembang untuk memisahkan masalah teknis jaringan dengan kesalahan struktur data dari server.
7. **Penanganan *Timeout* Respons API**: Pesan peringatan khusus "Oops! It took longer to respond" diaktifkan jika server tidak merespons dalam 60 detik, memberikan kejelasan status pada kasir.
8. **Validasi Input Real-Time**: Penggunaan library `validatorless` untuk memastikan data yang dimasukkan (seperti email, nominal stok, atau password) sudah sesuai format sebelum tombol "Kirim" aktif.
9. **Pembersihan Sesi Total (*Deep Logout*)**: Fungsi `removeToken` memastikan seluruh jejak data sensitif (Akses, User, Produk, hingga MAC Printer) dihapus sepenuhnya dari cache perangkat saat kasir keluar.

---

## 26. Detail UI/UX & Mekanisme Sinkronisasi

Aspek desain visual dan pengalaman pengguna yang mengoptimalkan produktivitas kasir di lapangan.

### A. Estetika & Interaksi Visual
10. **Tipografi Premium (Font *Outfit*)**: Pengunaan font keluarga `Outfit` secara global untuk memberikan kesan antarmuka yang modern, bersih, dan profesional.
11. **Skema Warna Tombol Aksi (*BlueLight*)**: Konsistensi penggunaan palet biru khusus untuk memandu mata kasir ke tombol aksi utama (seperti tombol "Bayar" atau "Simpan").
12. **Indikator Progres Reaktif**: Tampilan `CircularProgressIndicator` yang sinkron dengan status asinkronus sistem, memberikan kepastian visual bahwa proses data sedang berlangsung.
13. **Optimasi Scroll Layar Kecil**: Penggunaan `SingleChildScrollView` pada seluruh jendela popup untuk memastikan formulir input tetap dapat diakses meski tertutup oleh keyboard virtual pada tablet berukuran kecil.
14. **Desain Sidebar Dinamis**: Sidebar navigasi yang dapat diperlebar menjadi mode *Extended* untuk menampilkan label yang jelas atau dipersempit untuk efisiensi ruang layar.
15. **Constraint Aspek Rasio**: Layout yang dikunci khusus untuk layar tablet (Landscape Only), memastikan elemen UI tidak melar atau terpotong saat dipindahkan antar merk tablet yang berbeda.

### B. Sinkronisasi & Standar Data
16. **Fitur *Pull-to-Refresh* Manual**: Kasir dapat melakukan tarik-layar-ke-bawah (*Pull-to-Refresh*) pada daftar stok dan menu untuk memaksa sinkronisasi data manual dari server.
17. **Metadata Deskripsi Menu (*Product Details*)**: Sistem menarik deskripsi panjang dari backend untuk ditampilkan pada layar kasir jika pelanggan membutuhkan informasi detail tentang menu tersebut.
18. **Logika Kontroler `ever` (GetX)**: Pemicu aksi otomatis (seperti penarikan ulang data pesanan) secara instan setiap kali variabel status online/offline berubah.
19. **Standar Waktu `formatDateTemplateJustTime`**: Penyeragaman tampilan jam (HH:mm) di seluruh struk dan sistem laporan untuk akurasi durasi shift.

---

**Catatan Akhir**: Panduan ini mencakup seluruh logika bisnis operasional SB POS. Untuk perubahan konfigurasi server atau debug teknis mendalam, silakan merujuk pada `README.md` pengembang.
