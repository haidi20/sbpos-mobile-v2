import 'dart:collection';

import 'package:core/data/datasources/db/auth_user.table.dart';

class CoreDatabaseSchemaTable {
  const CoreDatabaseSchemaTable({
    required this.name,
    required this.createTableQuery,
    this.createIndexQueries = const [],
  });

  final String name;
  final String createTableQuery;
  final List<String> createIndexQueries;

  String get ensureTableQuery => createTableQuery.replaceFirst(
        RegExp(r'CREATE TABLE', caseSensitive: false),
        'CREATE TABLE IF NOT EXISTS',
      );
}

class CoreDatabaseSchemaRegistry {
  CoreDatabaseSchemaRegistry._();

  static final CoreDatabaseSchemaRegistry instance =
      CoreDatabaseSchemaRegistry._();

  static final LinkedHashMap<String, CoreDatabaseSchemaTable> _defaultTables =
      LinkedHashMap<String, CoreDatabaseSchemaTable>.from({
    AuthUserTable.tableName: const CoreDatabaseSchemaTable(
      name: AuthUserTable.tableName,
      createTableQuery: AuthUserTable.createTableQuery,
      createIndexQueries: [AuthUserTable.createIndexUsername],
    ),
  });

  final LinkedHashMap<String, CoreDatabaseSchemaTable> _tables =
      LinkedHashMap<String, CoreDatabaseSchemaTable>.from(_defaultTables);

  List<CoreDatabaseSchemaTable> get tables => List.unmodifiable(_tables.values);

  List<String> get createTableQueries => [
        for (final table in _tables.values) table.createTableQuery,
      ];

  List<String> get ensureTableQueries => [
        for (final table in _tables.values) table.ensureTableQuery,
      ];

  List<String> get createIndexQueries => [
        for (final table in _tables.values) ...table.createIndexQueries,
      ];

  List<String> get storeNames => [
        for (final table in _tables.values) table.name,
      ];

  void registerTable(CoreDatabaseSchemaTable table) {
    _tables[table.name] = table;
  }

  void registerTables(Iterable<CoreDatabaseSchemaTable> tables) {
    for (final table in tables) {
      registerTable(table);
    }
  }

  void resetToDefaults() {
    _tables
      ..clear()
      ..addAll(_defaultTables);
  }
}
