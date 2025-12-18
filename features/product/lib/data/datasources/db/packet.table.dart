class PacketTable {
  static const String tableName = 'packets';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colName = 'name';
  static const String colPrice = 'price';
  static const String colIsActive = 'is_active';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';
  static const String colSyncedAt = 'synced_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER UNIQUE,
      $colName TEXT,
      $colPrice INTEGER,
      $colIsActive INTEGER,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colDeletedAt TEXT NULL,
      $colSyncedAt TEXT NULL
    )
  ''';
}
