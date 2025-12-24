// Platform detection shim: uses `dart:io` on IO platforms and `kIsWeb` on web.
import 'platform_detect_io.dart'
    if (dart.library.html) 'platform_detect_web.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

import 'core_database_mobile.dart';
import 'core_database_desktop.dart';
import 'local_database_sembast.dart' as sembast_local;

/// Dispatcher that chooses the correct CoreDatabase implementation at runtime.
///
/// Selection order:
/// 1. Environment override via `CORE_DB_PLATFORM` in dotenv: 'mobile' or 'desktop'.
/// 2. Platform detection: Android/iOS/Fuchsia => mobile; Windows/Linux/MacOS => desktop.
/// 3. Fallback to mobile.
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
    // 0) If running on web, use Sembast-backed LocalDatabase adapter.
    try {
      if (PlatformDetect.isWeb) {
        _logger.info('CoreDatabase: selected web implementation (sembast)');
        _impl = _WebCoreImpl();
        return;
      }
    } catch (e, st) {
      _logger.fine('PlatformDetect.isWeb check failed', e, st);
    }

    // 1) Runtime override (highest priority) - can be set programmatically
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

    // 2) Env override (useful for tests or explicit forcing via .env)
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

    // 2) Platform detection
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

  /// Programmatically force the platform selection. Use 'mobile', 'desktop',
  /// or null to clear the runtime override and fall back to env/platform.
  static void setPlatformOverride(String? platform) {
    _runtimeOverride = platform?.toLowerCase();
    // reset instance so next access re-evaluates selection
    if (_instance != null) _instance!._impl = null;
  }

  /// Inspect the currently chosen platform without forcing initialization.
  /// Returns 'mobile' or 'desktop'. If not yet selected, attempts to evaluate
  /// overrides and platform detection heuristics.
  String selectedPlatform() {
    // if already decided
    if (_impl != null) {
      final name = _impl.runtimeType.toString().toLowerCase();
      return name.contains('desktop') ? 'desktop' : 'mobile';
    }

    // evaluate without creating implementation
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

/// Minimal web adapter that initializes `LocalDatabase` (Sembast) and returns
/// `null` for `.database` to preserve existing DAO fallback logic that uses
/// `LocalDatabase` when CoreDatabase returns `null`.
class _WebCoreImpl {
  Future<dynamic> get database async {
    try {
      await sembast_local.LocalDatabase.instance.init();
      // Return null intentionally: DAO-level code treats a null `.database`
      // as the signal to use the web Sembast `LocalDatabase` fallback.
      return null;
    } catch (e, st) {
      Logger('CoreDatabaseWeb').severe('Failed to init LocalDatabase', e, st);
      return null;
    }
  }
}
