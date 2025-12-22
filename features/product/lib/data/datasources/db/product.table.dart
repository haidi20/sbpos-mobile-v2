class ProductTable {
  static const String tableName = 'products';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colCode = 'code';
  static const String colName = 'name';
  static const String colSlug = 'slug';
  static const String colType = 'type';
  static const String colBarcodeSymbology = 'barcode_symbology';
  static const String colCategoryId = 'category_id';
  static const String colUnitId = 'unit_id';
  static const String colBusinessId = 'business_id';
  static const String colCost = 'cost';
  static const String colQty = 'qty';
  static const String colAlertQuantity = 'alert_quantity';
  static const String colImage = 'image';
  static const String colProductDetails = 'product_details';
  static const String colIsActive = 'is_active';
  static const String colIsDiffPrice = 'is_diff_price';
  static const String colCategoryParentId = 'category_parent_id';
  static const String colCategoryParentName = 'category_parent_name';
  static const String colGofoodPrice = 'gofood_price';
  static const String colGrabfoodPrice = 'grabfood_price';
  static const String colShopeefoodPrice = 'shopeefood_price';
  static const String colPrice = 'price';
  static const String colStock = 'stock';
  static const String colSyncedAt = 'synced_at';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER UNIQUE,
      $colSlug TEXT,
      $colCode TEXT,
      $colType TEXT,
      $colBarcodeSymbology TEXT,
      $colCategoryId INTEGER,
      $colUnitId INTEGER,
      $colBusinessId INTEGER,
      $colCost REAL,
      $colName TEXT,
      $colPrice REAL,
      $colQty REAL,
      $colStock INTEGER,
      $colAlertQuantity REAL,
      $colImage TEXT,
      $colProductDetails TEXT,
      $colIsActive INTEGER,
      $colIsDiffPrice INTEGER,
      $colCategoryParentId INTEGER,
      $colCategoryParentName TEXT,
      $colGofoodPrice REAL,
      $colGrabfoodPrice REAL,
      $colShopeefoodPrice REAL,
      $colSyncedAt TEXT NULL,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colDeletedAt TEXT NULL
    )
  ''';

  // Index untuk pencarian nama produk.
  static const String createIndexName =
      'CREATE INDEX IF NOT EXISTS idx_product_name ON $tableName($colName)';
}
