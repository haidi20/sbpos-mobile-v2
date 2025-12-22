class CustomerTable {
  static const String tableName = 'customers';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colName = 'name';
  static const String colPhone = 'phone';
  static const String colNote = 'note';
  static const String colEmail = 'email';
  static const String colSyncedAt = 'synced_at';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER,
      $colName TEXT,
      $colPhone TEXT,
      $colNote TEXT,
      $colEmail TEXT,
      $colSyncedAt TEXT NULL,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colDeletedAt TEXT NULL
    )
  ''';

  // Index untuk pencarian nama pelanggan.
  static const String createIndexName =
      'CREATE INDEX IF NOT EXISTS idx_customer_name ON $tableName($colName)';
}
