// Export kondisional untuk sqflite pada platform native dan stub web untuk build web.
export 'platform_db_native.dart' if (dart.library.html) 'platform_db_web.dart';
