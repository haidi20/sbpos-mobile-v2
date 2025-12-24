// Shim deteksi platform: menggunakan `dart:io` pada platform IO dan `kIsWeb` pada web.
import 'platform_detect_io.dart'
    if (dart.library.html) 'platform_detect_web.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

import 'core_database_mobile.dart';
import 'core_database_desktop.dart';
import 'local_database_sembast.dart' as sembast_local;

/// Dispatcher yang memilih implementasi CoreDatabase yang tepat saat runtime.
///
/// Urutan pemilihan:
/// 1. Override dari environment melalui `CORE_DB_PLATFORM` di dotenv: 'mobile' atau 'desktop'.
/// 2. Deteksi platform: Android/iOS/Fuchsia => mobile; Windows/Linux/MacOS => desktop.
/// 3. Jika gagal, fallback ke mobile.
class CoreDatabase {
  static CoreDatabase? _instance;
  CoreDatabase._internal();
  factory CoreDatabase() => _instance ??= CoreDatabase._internal();

  dynamic _impl;
  static String? _runtimeOverride;
  final _logger = Logger('CoreDatabase');

  Future<dynamic> get database async {
    _ensureImpl();
    try {
      return await _impl.database;
    } catch (e, st) {
      _logger.severe('Failed to get database from impl', e, st);
      return null;
    }
  }

  void _ensureImpl() {
    if (_impl != null) return;
    // 0) Jika berjalan di web, gunakan adapter LocalDatabase berbasis Sembast.
    try {
      if (PlatformDetect.isWeb) {
        _logger.info('CoreDatabase: selected web implementation (sembast)');
        _impl = _WebCoreImpl();
        return;
      }
    } catch (e, st) {
      _logger.fine('PlatformDetect.isWeb check failed', e, st);
    }

    // 1) Override runtime (prioritas tertinggi) - dapat di-set secara programatis
    try {
      final runtime = _runtimeOverride?.toLowerCase();
      if (runtime != null && runtime.isNotEmpty) {
        if (runtime == 'desktop') {
          _logger.info(
              'CoreDatabase: forcing desktop implementation via runtime override');
          _impl = CoreDatabaseDesktop();
          return;
        } else if (runtime == 'mobile') {
          _logger.info(
              'CoreDatabase: forcing mobile implementation via runtime override');
          _impl = CoreDatabaseMobile();
          return;
        }
      }
    } catch (e, st) {
      _logger.fine('Runtime override check failed', e, st);
    }

    // 2) Override dari env (berguna untuk pengujian atau memaksa lewat .env)
    try {
      final override = dotenv.env['CORE_DB_PLATFORM']?.toLowerCase();
      if (override != null && override.isNotEmpty) {
        if (override == 'desktop') {
          _logger.info(
              'CoreDatabase: forcing desktop implementation via CORE_DB_PLATFORM');
          _impl = CoreDatabaseDesktop();
          return;
        } else if (override == 'mobile') {
          _logger.info(
              'CoreDatabase: forcing mobile implementation via CORE_DB_PLATFORM');
          _impl = CoreDatabaseMobile();
          return;
        }
      }
    } catch (e, st) {
      _logger.fine('CORE_DB_PLATFORM override check failed', e, st);
    }

    // 2) Deteksi platform
    try {
      if (PlatformDetect.isAndroid ||
          PlatformDetect.isIOS ||
          PlatformDetect.isFuchsia) {
        _logger.info('CoreDatabase: selected mobile implementation (Platform)');
        _impl = CoreDatabaseMobile();
        return;
      }

      if (PlatformDetect.isWindows ||
          PlatformDetect.isLinux ||
          PlatformDetect.isMacOS) {
        _logger
            .info('CoreDatabase: selected desktop implementation (Platform)');
        _impl = CoreDatabaseDesktop();
        return;
      }
    } catch (e, st) {
      _logger.fine('Platform detection failed, falling back', e, st);
    }

    // 3) Fallback
    _logger.info('CoreDatabase: falling back to mobile implementation');
    _impl = CoreDatabaseMobile();
  }

  /// Memaksa pemilihan platform secara programatis. Gunakan 'mobile', 'desktop',
  /// atau null untuk menghapus override runtime dan kembali ke pengecekan env/platform.
  static void setPlatformOverride(String? platform) {
    _runtimeOverride = platform?.toLowerCase();
    // reset instance agar akses berikutnya mengevaluasi ulang pemilihan
    if (_instance != null) _instance!._impl = null;
  }

  /// Periksa platform yang dipilih saat ini tanpa memaksa inisialisasi.
  /// Mengembalikan 'mobile' atau 'desktop'. Jika belum dipilih, mencoba mengevaluasi
  /// override dan heuristik deteksi platform.
  String selectedPlatform() {
    // jika sudah diputuskan
    if (_impl != null) {
      final name = _impl.runtimeType.toString().toLowerCase();
      return name.contains('desktop') ? 'desktop' : 'mobile';
    }

    // evaluasi tanpa membuat implementasi
    final runtime = _runtimeOverride?.toLowerCase();
    if (runtime == 'desktop' || runtime == 'mobile') return runtime!;
    final override = dotenv.env['CORE_DB_PLATFORM']?.toLowerCase();
    if (override == 'desktop' || override == 'mobile') return override!;

    try {
      if (PlatformDetect.isWindows ||
          PlatformDetect.isLinux ||
          PlatformDetect.isMacOS) {
        return 'desktop';
      }
      if (PlatformDetect.isAndroid ||
          PlatformDetect.isIOS ||
          PlatformDetect.isFuchsia) {
        return 'mobile';
      }
    } catch (_) {}
    return 'mobile';
  }
}

/// Adapter web minimal yang menginisialisasi `LocalDatabase` (Sembast) dan mengembalikan
/// `null` untuk `.database` agar mempertahankan logika fallback DAO yang menggunakan
/// `LocalDatabase` ketika CoreDatabase mengembalikan `null`.
class _WebCoreImpl {
  Future<dynamic> get database async {
    try {
      await sembast_local.LocalDatabase.instance.init();
      // Mengembalikan null dengan sengaja: kode di level DAO memperlakukan null `.database`
      // sebagai sinyal untuk menggunakan fallback `LocalDatabase` Sembast di web.
      return null;
    } catch (e, st) {
      Logger('CoreDatabaseWeb').severe('Failed to init LocalDatabase', e, st);
      return null;
    }
  }
}
