# Panduan Setup Firebase SB POS

Ikuti langkah-langkah di bawah ini untuk mengaktifkan **Error Reporting (Crashlytics)** secara penuh di perangkat Anda.

## 1. Dapatkan File Konfigurasi
Buka [Console Firebase](https://console.firebase.google.com/), pilih proyek Anda, dan unduh file berikut:
- **Android**: `google-services.json`
- **iOS**: `GoogleService-Info.plist`

## 2. Letakkan File pada Direktori yang Benar

### Android
Letakkan file `google-services.json` di:
`android/app/google-services.json`

### iOS
1. Buka folder `ios/` menggunakan **Xcode**.
2. Klik kanan pada folder `Runner` di navigasi kiri Xcode.
3. Pilih **"Add Files to 'Runner'..."**.
4. Pilih file `GoogleService-Info.plist` yang sudah diunduh.
5. Pastikan opsi **"Copy items if needed"** dicentang dan klik **Add**.

## 3. Verifikasi
Setelah file diletakkan, jalankan perintah berikut di terminal untuk memastikan tidak ada error saat build:

```powershell
flutter clean
flutter pub get
```

## 4. Testing Crash (Optional)
Untuk mengetes apakah Crashlytics sudah bekerja, Anda bisa menambahkan kode sementara di `main.dart`:
```dart
FirebaseCrashlytics.instance.crash();
```
Jalankan aplikasi, dan periksa dashboard Firebase Crashlytics setelah 5-10 menit.

> [!IMPORTANT]
> Proyek ini sudah dikonfigurasi dengan plugin Gradle (`google-services` & `crashlytics`). Anda hanya perlu menambahkan file JSON/Plist di atas agar sinkronasi berjalan.
