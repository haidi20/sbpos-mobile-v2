# Panduan DataSource: Transaction

Panduan ini mendokumentasikan perilaku DataSource dan Repository untuk fitur Transaction berdasarkan implementasi aktual di kode:
- `features/transaction/lib/data/repositories/transaction.repository_impl.dart`
- `features/transaction/lib/data/datasources/**`

Dokumen ini fokus pada: skema tabel lokal, perilaku DAO, kontrak Local/Remote Data Source, serta alur Repository termasuk mode offline/online dan aturan sinkronisasi.

---

### 1. Struktur Tabel Lokal (SQLite)

Tabel utama dan detail, sesuai file definisi:

- `db/transaction.table.dart` (tabel: `transactions`) *tergantung model yang ingin dibuat
	- Kolom: `id`, `id_server`, `shift_id`, `outlet_id`, `sequence_number`, `order_type_id`, `category_order`, `user_id`, `payment_method`, `date`, `notes`, `total_amount`, `total_qty`, `paid_amount`, `change_money`, `status`, `cancelation_otp`, `cancelation_reason`, `created_at`, `updated_at`, `deleted_at`, `synced_at`.
- `db/transaction_detail.table.dart` (tabel: `transaction_details`)
	- Kolom: `id`, `id_server`, `transaction_id`, `product_id`, `product_name`, `product_price`, `qty`, `subtotal`, `created_at`, `updated_at`, `deleted_at`, `synced_at`, `note`.

Catatan:
- Default status lokal untuk transaksi baru adalah `'Pending'` (lihat DAO dan model).
- `synced_at` bertipe teks ISO8601 dan boleh `NULL`.

---

### 2. Remote Data Source

File: `transaction_remote_data_source.dart`

- Base URL: `'$HOST/$API'` (variabel `HOST` dan `API` dari `core`).
- Endpoints & method:
	- GET `.../transactions` → `fetchTransactions({params})` → `TransactionResponse`.
	- POST `.../transactions` → `postTransaction(payload)` → `TransactionResponse`.
	- GET `.../transactions/:id` → `getTransaction(id)` → `TransactionResponse`.
	- PUT `.../transactions/:id` → `updateTransaction(id, payload)` → `TransactionResponse`.
	- DELETE `.../transactions/:id` → `deleteTransaction(id)` → `TransactionResponse`.
- Semua request dibungkus `handleApiResponse` dari `core` dan respons didecode via `TransactionResponse.fromJson`.

---

### 3. Local Data Source

File: `transaction_local_data_source.dart`

Kontrak & perilaku penting:
- `getTransactions()` → `List<TransactionModel>`; mapping termasuk detail.
- `getTransactionById(int id)` → `TransactionModel?`.
- `getLatestTransaction()` → `TransactionModel?` (urut `created_at DESC LIMIT 1`).
- `insertTransaction(TransactionModel)` → `TransactionModel?`
	- Melalui DAO, memaksa `synced_at = NULL` untuk insert pertama kali.
	- Menjaga default `status = 'Pending'` bila tidak terisi.
- `insertSyncTransaction(TransactionModel)` → `TransactionModel?`
	- Insert transaksi dan seluruh `details` secara atomik (single DB transaction).
- `insertDetails(List<TransactionDetailModel>)` → `List<TransactionDetailModel>?`
	- Jika sudah ada detail dengan pasangan `(transaction_id, product_id)`, maka: `qty` dijumlah, `subtotal` dihitung ulang = `price * qtyBaru`, `updated_at` diupdate.
- `deleteDetailsByTransactionId(int)` → `int` (jumlah row terhapus).
- `updateTransaction(Map<String, dynamic>)` → `int` (affected rows)
	- Input diproses `sanitizeForDb` untuk menghapus `null` values.
	- Kunci `id` tetap dipertahankan sebagai filter `WHERE id = ?` di DAO.
- `deleteTransaction(int)` → `int`.

Utility:
- `sanitizeForDb(Map)` dari mixin `BaseErrorHelper` (core) dipakai untuk memastikan map siap untuk DB (menghapus `null`, format tanggal ISO, dll.).
- `_withRetry` melakukan retry ringan untuk error transien.

---

### 4. DAO (Database Access Object)

File: `db/transaction.dao.dart`

Metode utama dan aturan:
- `getTransactions()`
	- Query semua baris `transactions`, lalu ambil `transaction_details` per transaksi, kembalikan `TransactionModel` lengkap dengan `details`.
- `getTransactionById(int id)` → data + details untuk `id` tertentu.
- `getLatestTransaction()` → baris terbaru (urut `created_at` desc) lengkap dengan details.
- `insertTransaction(Map tx)`
	- Memastikan `tx['synced_at'] = NULL` saat insert pertama kali.
	- Membersihkan `null` keys; default `status = 'Pending'` bila kosong.
	- Mengembalikan `TransactionModel` tanpa details (details bisa diinsert terpisah).
- `insertSyncTransaction(Map tx, List<Map> details)`
	- Insert transaksi dan setiap detail (memastikan `transaction_id` terisi) dalam 1 transaksi DB.
	- Default `status = 'Pending'` bila kosong.
- `updateTransaction(Map tx)`
	- Menghapus `id` dari map update (digunakan hanya di clause `WHERE`).
- `deleteTransaction(int id)`, `clearTransactions()`.
- `getDetailsByTransactionId(int)`, `insertDetails(List<Map>)`, `deleteDetailsByTransactionId(int)`
	- `insertDetails`: bila ada baris existing untuk `(transaction_id, product_id)`, maka update baris existing: `qty` dijumlah, `subtotal = price * qtyBaru`, set `updated_at = now`.

---

### 5. ketika isOffline, isConnected == false, dan ketika gagal kirim remote saat create dan update

Wajib memastikan kolom `synced_at` menjadi `NULL` pada record transaksi lokal untuk menandakan data belum tersinkron ke server. Ketentuan ini berlaku pada skenario:
- `isOffline == true` (pemanggil memaksa mode offline).
- Perangkat tidak terhubung internet (`isConnected == false`).
- Gagal mengirim ke remote (exception server/jaringan) saat operasi `create` atau `update`.

Rasional & implementasi aktual:
- Insert lokal pertama lewat DAO sudah memaksa `synced_at = NULL` (`insertTransaction`).
- Pada `setTransaction/createTransaction`:
	- Insert lokal dilakukan terlebih dahulu (hasil `synced_at = NULL`).
	- Jika online dan create ke server sukses, baris lokal diupdate dengan `id_server` dan `synced_at = now()`; bila gagal, tetap biarkan `synced_at = NULL`.
- Pada `updateTransaction`:
	- Update lokal dilakukan dahulu. Jika offline/tidak terhubung/gagal update remote, kembalikan data lokal apa adanya. Untuk konsistensi sinkronisasi, kebijakan proyek ini mengharuskan `synced_at` dipastikan `NULL` pada kondisi gagal sinkron ini.

Checklist penerapan (saat menambah/ubah kode):
- Ketika path eksekusi berakhir di fallback lokal (offline/failed remote), jangan set `synced_at` ke nilai waktu; biarkan `NULL` atau set eksplisit ke `NULL` via `updateTransaction`.
- Hanya set `synced_at = now()` setelah respons remote sukses dan data lokal telah diperbarui.

API pendukung yang dipakai di kode (Transaction):
- DAO: `TransactionDao.clearSyncedAt(int id)` → raw SQL `UPDATE ... SET synced_at = NULL WHERE id = ?`.
- Local DS: `TransactionLocalDataSource.clearSyncedAt(int id)` → membungkus pemanggilan DAO.
- Repository: di `updateTransaction(...)`, `clearSyncedAt` dipanggil pada tiga kondisi (offline, tidak ada koneksi, gagal remote) untuk menjamin `synced_at` benar-benar `NULL`.
- Catatan untuk create: insert pertama melalui DAO sudah memaksa `synced_at = NULL`, sehingga tidak perlu pemanggilan eksplisit `clearSyncedAt` pada jalur gagal/offline.

---

### 6. Alur di Repository

File: `transaction.repository_impl.dart`

Ringkasan alur per operasi:

- `getDataTransactions({isOffline})`
	- Jika `isOffline == true` → langsung ambil lokal (return list meskipun kosong).
	- Cek koneksi. Jika online: GET remote → bila sukses dan ada data, simpan per item ke lokal via `local.insertTransaction` dan kembalikan Entity hasil simpan; jika gagal/empty → fallback ke lokal.
	- Jika offline/tidak terhubung → fallback ke lokal.

- `createTransaction(transaction, {isOffline})` / `setTransaction(...)`
	- Insert lokal lebih dulu (`insertTransaction`) → detail disimpan (mapping `transaction_id` lokal).
	- Jika `isOffline == true` → return hasil lokal langsung (tanpa sync).
	- Jika online: POST → bila sukses, update lokal: set `id_server` dan `synced_at = now()`; bila gagal exception/invalid response → kembalikan hasil lokal (tetap `synced_at = NULL`).

- `getTransaction(id, {isOffline})`
	- Offline/forced offline → ambil lokal.
	- Online → GET remote; bila sukses, simpan sinkron ke lokal (`insertSyncTransaction`) dan return; bila gagal → fallback ke lokal.

- `getLatestTransaction({isOffline})`
	- Offline/forced offline → ambil lokal latest.
	- Online → GET list remote, pilih terbaru berdasar `created_at` desc; coba simpan sinkron ke lokal; return yang terbaru.

- `updateTransaction(transaction, {isOffline})`
	- Jika `id` lokal null → delegasikan ke `setTransaction` (treat as create) agar pasti ada baris lokal.
	- Update lokal terlebih dulu; replace details: hapus semua by `transaction_id`, lalu `insertDetails` baru.
	- Offline/forced offline → return lokal.
	- Cek koneksi: jika offline → return lokal.
	- Jika `id_server` null → treat as create (POST) via `createTransaction`.
	- Jika online: PUT remote → ketika sukses, update lokal `id_server` dan `synced_at = now()`; bila gagal exception/invalid response → panggil `local.clearSyncedAt(id)` lalu return lokal (memastikan `synced_at = NULL` sesuai aturan di Bagian 5).

Catatan konsistensi lintas modul:
- Fitur Customer menerapkan aturan yang sama: pada create/update ketika offline, tidak ada koneksi, atau gagal remote → `synced_at` dijamin `NULL` (melalui insert awal yang men-NULL-kan atau pemanggilan `clearSyncedAt`).

- `deleteTransaction(id, {isOffline})`
	- Selalu hapus lokal terlebih dahulu, lalu:
		- Offline/forced offline → return `true`.
		- Online → coba DELETE remote; apapun hasilnya, return `true` (optimistic deletion).

---

### 7. Catatan Implementasi

- `TransactionModel.toInsertDbLocal()` dan `TransactionDetailModel.toInsertDbLocal()` memasukkan nilai tanggal sebagai ISO string; `change_money` dipastikan non-null (0) dan `status` disimpan sebagai string (`'Pending'|'Lunas'|'Batal'`).
- DAO menghapus `null` key sebelum operasi insert/update agar schema konsisten.
- `insertDetails` menggunakan logika upsert sederhana berdasarkan `(transaction_id, product_id)` untuk menjumlah `qty` dan menghitung ulang `subtotal`.

### 8. Catatan Tambahan: Aturan id vs idServer (Local vs Server)

Definisi singkat:
- **`id` (lokal)**: Primary key di SQLite (autoincrement). Hanya berlaku di perangkat.
- **`idServer` (remote)**: Identifier dari server (API). Dipakai saat kirim/ambil data ke/dari server.

Aturan mapping yang wajib diikuti:
- fromJson (data dari server → model lokal)
	- `idServer = _toInt(json['id'])` (atau `json['id_server']` bila API mengembalikan field tersebut)
	- `id` TIDAK diisi dari JSON server. Biarkan `id` (lokal) dikelola SQLite saat insert.

- toJson (model → payload ke server)
	- `id = idServer` (field `id` di payload harus berisi id server, bukan id lokal)
	- `id_server = idServer` (opsional; isi jika backend juga menerima/menyimpan kolom ini)

Contoh implementasi minimal pada Model:

```dart
factory XModel.fromJson(Map<String, dynamic> json) => XModel(
	// id lokal sengaja tidak diisi dari server
	idServer: _toInt(json['id'] ?? json['id_server']),
	// .. field lain
);

Map<String, dynamic> toJson() => {
	// saat kirim, gunakan idServer sebagai id
	'id': idServer,
	'id_server': idServer, // jika API juga memakai id_server
	// .. field lain
};
```

Implikasi pada alur create/update:
- Create lokal (offline/awal):
	- Insert ke DB dengan `id = null` (autoincrement), `idServer = null`, dan `synced_at = NULL` (belum tersinkron).
- Create remote sukses:
	- Update baris lokal: set `id_server` dari respons server dan `synced_at = now()`.
- Update ke server:
	- Wajib punya `idServer` (jika `idServer == null`, treat as create). Payload kirim `'id': idServer`.
- Gagal kirim (offline / no-connection / server error):
	- Pastikan `synced_at = NULL` pada baris lokal (gunakan helper `clearSyncedAt`).

---

Dokumen ini bersifat sumber rujukan baku untuk pengembangan Transaction DataSource & Repository. Jika ada perubahan kode, mohon sinkronkan panduan ini agar selalu konsisten dengan implementasi.
