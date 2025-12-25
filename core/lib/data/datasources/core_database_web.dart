import 'package:core/core.dart';
import 'local_database_sembast.dart' as sembast_db;

/// Web CoreDatabase helper: perform one-time schema initialization for web
/// (Sembast) so stores and index metadata exist similarly to SQL tables.
///
/// Note: This returns `null` to preserve existing fallback logic where
/// DAOs detect `db == null` and use the web mixin helpers. The side-effect
/// is that `LocalDatabase.instance` will be initialized and stores created.
class CoreDatabase {
  static CoreDatabase? _databaseHelper;
  CoreDatabase._instance() {
    _databaseHelper = this;
  }

  factory CoreDatabase() => _databaseHelper ?? CoreDatabase._instance();

  static final Logger _logger = Logger('CoreDatabase');

  Future<dynamic> get database async {
    // _logger.info('Initializing LocalDatabase schema for web');
    try {
      final local = sembast_db.LocalDatabase.instance;
      await local.init();

      // Ensure stores exist by creating a temporary metadata record then
      // clearing it. This guarantees the store is present for later ops.
      final stores = [
        'auth_users',
        'outlets',
        'packets',
        'products',
        'packet_items',
        'transactions',
        'transaction_details',
        'customers',
      ];

      for (final s in stores) {
        try {
          // Only ensure store exists without deleting user data.
          // If store is empty, create a temporary record and remove it by key.
          final existing = await local.getAll(s);
          if (existing.isEmpty) {
            final key = await local.insert(s, {
              '__init': true,
              '__created_at': DateTime.now().toIso8601String()
            });
            try {
              await local.deleteByKey(s, key);
            } catch (_) {}
          }
        } catch (e, st) {
          _logger.warning('Failed to ensure store $s', e, st);
        }
      }

      try {
        await local.deleteAll('__db_indexes');
        // for (final e in indexMeta.entries) {
        // await local
        //     .insert('__db_indexes', {'name': e.key, 'fields': e.value});
        // }
      } catch (e, st) {
        _logger.warning('Failed to write index metadata', e, st);
      }

      // _logger.info('Web LocalDatabase schema initialization complete');
    } catch (e, st) {
      _logger.warning('Failed to initialize web schema', e, st);
    }

    // Keep returning null so existing DAOs fall back to web mixins.
    return null;
  }
}
