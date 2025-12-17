class PacketItemTable {
  static const String tableName = 'packet_items';

  static const String colId = 'id';
  static const String colPacketId = 'packet_id';
  static const String colProductId = 'product_id';
  static const String colQty = 'qty';
  static const String colSubtotal = 'subtotal';
  static const String colDiscount = 'discount';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colPacketId INTEGER,
      $colProductId INTEGER,
      $colQty INTEGER,
      $colSubtotal INTEGER,
      $colDiscount INTEGER DEFAULT 0,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL
    )
  ''';
}
