// Minimal stub for sqflite symbols when compiling to web.

import 'dart:async';

class Database {
  Future<void> execute(String sql) async {}
  Future<void> close() async {}
}

Future<String> getDatabasesPath() async {
  throw UnsupportedError('sqflite is not supported on web');
}

Future<Database> openDatabase(
  String path, {
  int? version,
  FutureOr<void> Function(Database db, int version)? onCreate,
  FutureOr<void> Function(Database db)? onOpen,
}) async {
  throw UnsupportedError('sqflite is not supported on web');
}
