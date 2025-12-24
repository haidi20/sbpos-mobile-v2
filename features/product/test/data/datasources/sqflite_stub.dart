// Stub implementations for analyzer when native sqflite_ffi isn't available.
// On native (dart:io) platforms, this file will be conditionally replaced
// by the real `sqflite_common_ffi` exports.

void sqfliteFfiInit() {}

// Minimal stubs to satisfy tests at analysis time.
// `databaseFactoryFfi` and `inMemoryDatabasePath` are provided as dynamic
// values; tests that actually run on native should use the real package.

const databaseFactoryFfi = null;
const String inMemoryDatabasePath = ':memory:';
