class ProductTable {
  static const String tableName = 'products';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colCode = 'code';
  static const String colName = 'name';
  static const String colPrice = 'price';
  static const String colStock = 'stock';
  static const String colSyncedAt = 'synced_at';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER,
      $colCode TEXT,
      $colName TEXT,
      $colPrice REAL,
      $colStock INTEGER,
      $colSyncedAt TEXT NULL,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colDeletedAt TEXT NULL
    )
  ''';
}
