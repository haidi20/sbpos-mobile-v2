class TransactionDetailTable {
  static const String tableName = 'transaction_details';

  static const String colId = 'id';
  static const String colTransactionId = 'transaction_id';
  static const String colProductId = 'product_id';
  static const String colProductName = 'product_name';
  static const String colProductPrice = 'product_price';
  static const String colPacketId = 'packet_id';
  static const String colPacketName = 'packet_name';
  static const String colPacketPrice = 'packet_price';
  static const String colQty = 'qty';
  static const String colSubtotal = 'subtotal';
  static const String colIdServer = 'id_server';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';
  static const String colSyncedAt = 'synced_at';
  static const String colNote = 'note';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER,
      $colTransactionId INTEGER,
      $colProductId INTEGER,
      $colProductName TEXT,
      $colProductPrice INTEGER,
      $colPacketId INTEGER,
      $colPacketName TEXT,
      $colPacketPrice INTEGER,
      $colQty INTEGER,
      $colSubtotal INTEGER,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colDeletedAt TEXT NULL,
      $colSyncedAt TEXT NULL,
      $colNote TEXT NULL
    )
  ''';
}
