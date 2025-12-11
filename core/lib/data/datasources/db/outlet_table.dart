class OutletTable {
  static const String tableName = 'outlets';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colName = 'name';
  static const String colAddress = 'address';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colSyncedAt = 'synced_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER,
      $colName TEXT,
      $colAddress TEXT NULL,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colSyncedAt TEXT NULL
    )
  ''';
}
