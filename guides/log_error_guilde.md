Saya akan membuat todo singkat untuk menyusun rekomendasi penyimpanan log dan opsi implementasinya.

Updated todo list

Ringkas (bahasa Indonesia), spesifik untuk fitur di help_screen.dart:

Rekomendasi utama — hybrid (direkomendasikan)
- Simpan ringkasan terstruktur ke DB (`error_logs`): id, level, message, short_stack, metadata(json), created_at, synced_at. Berguna untuk query, UI, dan filter saat user mengirim help.
- Simpan raw/verbose ke file log ter-rotasi (append), atau kumpulkan beberapa file terakhir jadi attachment. Berguna untuk debugging lengkap dan upload/attach ke tiket.
- Saat user kirim dari Help screen: ambil N entri terbaru dari `error_logs` (summary) + lampirkan satu file log terkompresi (mis .zip/.txt). Upload asinkron, tandai `synced_at` bila sukses.

Alasan:
- DB: mudah query dan menampilkan list error di UI sebelum kirim; bisa tandai, hapus, atau batch-upload.
- File: menyimpan stacktrace penuh, trace timelines, dan besar data tanpa membebani DB (menghindari locking).
- Hybrid memberi fleksibilitas dan performa yang baik.

Praktikal: schema & behavior
- Tambah tabel `error_logs` (contoh kolom):
  - `id INTEGER PRIMARY KEY`, `level TEXT`, `message TEXT`, `short_stack TEXT`, `metadata TEXT`, `created_at TEXT`, `synced_at TEXT NULL`
- File logger:
  - file path: gunakan `getApplicationDocumentsDirectory()` atau `getDatabasesPath()` parent; nama `app.log` + rotated `app.log.1`, dll.
  - rotasi: max size ~1MB atau per hari; simpan last 3 files.
  - compress saat attach (zip/gzip).
- Privacy & safety:
  - scrub PII from logs before persisting/upload.
  - minta persetujuan user jika mengirim data sensitif.
- Performance & robustness:
  - tulis file async (non-blocking).
  - tulis DB asinkron, batch insert untuk banyak event.
  - gunakan transactions untuk DB writes, hindari long-running locks.
  - implementasikan retention: hapus logs > 30/90 hari.

Integrasi Help screen (alur saat user kirim)
1. User buka help_screen.dart dan tulis pesan.
2. App mengambil N entri `error_logs` terakhir + compress file log terbaru.
3. Kirim payload: user message, device metadata, summaries (from DB), dan attachment file.
4. Jika upload sukses: update `error_logs.synced_at` dan move/rotate log file; beri notifikasi sukses ke user.

Opsi implementasi — pilih salah satu
- A (rekomendasi): Implement hybrid — saya buat patch: tambah `error_logs` table + ensureColumns + simple helper logger + sample send routine.
- B: Simpler: hanya file logger + attach file when sending (lebih cepat, kurang queryable).
- C: Integrasi Sentry/Crashlytics + local DB/file as fallback (recommended for production).

Mau saya implementasikan pilihan A sekarang (buat tabel + helper + migration)?
