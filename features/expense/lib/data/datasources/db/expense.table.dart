class ExpenseTable {
  static const String tableName = 'expenses';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colCategoryId = 'category_id';
  static const String colCategoryName = 'category_name';
  static const String colQty = 'qty';
  static const String colTotalAmount = 'total_amount';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colSyncedAt = 'synced_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER,
      $colCategoryId INTEGER,
      $colCategoryName TEXT,
      $colQty INTEGER,
      $colTotalAmount INTEGER,
      $colNotes TEXT,
      $colCreatedAt TEXT NULL,
      $colSyncedAt TEXT NULL
    )
  ''';

  static const String createIndexDate =
      'CREATE INDEX IF NOT EXISTS idx_expense_date ON $tableName($colCreatedAt)';
}
