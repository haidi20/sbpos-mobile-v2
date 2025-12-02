class CartTable {
  static const String tableName = 'carts';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colProductId = 'product_id';
  static const String colQty = 'qty';
  static const String colNote = 'note';
  static const String colPrice = 'price';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colSyncedAt = 'synced_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER,
      $colProductId INTEGER,
      $colQty INTEGER,
      $colNote TEXT NULL,
      $colPrice REAL NULL,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colSyncedAt TEXT NULL
    )
  ''';
}
