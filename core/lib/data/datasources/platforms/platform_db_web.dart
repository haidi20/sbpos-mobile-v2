// Pengganti kompatibel web minimal untuk API sqflite yang digunakan di aplikasi.
// Ini dibuat ringan agar build web tetap berhasil. Perilaku runtime yang lengkap
// sebaiknya diimplementasikan oleh adapter web yang sesuai (mis. sembast).

typedef Database = dynamic;

/// Minimal ConflictAlgorithm substitute to match sqflite API used in code.
enum ConflictAlgorithm { rollback, abort, fail, ignore, replace }

class Sqflite {
  /// Emulate Sqflite.firstIntValue behavior on a raw query result.
  static int? firstIntValue(List<Map<String, Object?>>? result) {
    if (result == null || result.isEmpty) return null;
    final row = result.first;
    if (row.isEmpty) return null;
    final value = row.values.first;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
