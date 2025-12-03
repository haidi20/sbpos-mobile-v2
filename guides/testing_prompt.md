# Catatan Prompt: Testing & Perbaikan Fitur Transaction

Prompt:
> flutter analyze feature transaction, perbaiki jika ada error. setelah aman running semua test transaction. perbaiki jika ada error. repeat sampai semua tuntas dan tidak ada kendala

## Langkah-langkah

1. **Analisis Kode**
    - Jalankan `flutter analyze features/transaction`
    - Catat dan perbaiki semua error/warning yang muncul.

2. **Jalankan Tes**
    - Setelah analisis bersih, jalankan semua tes di fitur transaction:
      - `flutter test features/transaction/test`
    - Perbaiki error/failure pada tes.

3. **Ulangi**
    - Ulangi proses analisis dan tes sampai tidak ada error/kendala.

## Tips

- Pastikan dependensi dan path sudah benar (`python update_path_module.py` jika perlu).
- Jika menambah helper atau utilitas, tambahkan ke `core/` dan ekspor via `core/lib/core.dart`.
- Gunakan Riverpod untuk state management dan ProviderScope di wrapper aplikasi.
- Untuk error handling, cek pola di `core/lib/utils/helpers/`.
