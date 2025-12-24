// Conditional export: use IO dispatcher on native platforms; web uses web impl.
// Runtime selection between mobile/desktop is handled inside the IO dispatcher
// (`core_database_io.dart`).
// (`core_database_io.dart`).
export 'core_database_io.dart' if (dart.library.html) 'core_database_web.dart';
