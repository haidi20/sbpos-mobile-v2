// Conditional export for LocalDatabase implementation.
export 'local_database_native.dart'
    if (dart.library.html) 'local_database_sembast.dart';
