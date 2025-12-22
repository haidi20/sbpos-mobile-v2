class TransactionTable {
  static const String tableName = 'transactions';

  static const String colId = 'id';
  static const String colIdServer = 'id_server';
  static const String colShiftId = 'shift_id';
  static const String colOutletId = 'outlet_id';
  static const String colSequenceNumber = 'sequence_number';
  static const String colOrderTypeId = 'order_type_id';
  static const String colCategoryOrder = 'category_order';
  static const String colUserId = 'user_id';
  static const String colCustomerId = 'customer_id';
  static const String colCustomerType = 'customer_type';
  static const String colPaymentMethod = 'payment_method';
  static const String colNumberTable = 'number_table';
  static const String colDate = 'date';
  static const String colNotes = 'notes';
  static const String colOjolProvider = 'ojol_provider';
  static const String colTotalAmount = 'total_amount';
  static const String colTotalQty = 'total_qty';
  static const String colPaidAmount = 'paid_amount';
  static const String colChangeMoney = 'change_money';
  static const String colStatus = 'status';
  static const String colIsPaid = 'is_paid';
  static const String colCancelationOtp = 'cancelation_otp';
  static const String colCancelationReason = 'cancelation_reason';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';
  static const String colSyncedAt = 'synced_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colIdServer INTEGER,
      $colShiftId INTEGER,
      $colOutletId INTEGER,
      $colSequenceNumber INTEGER,
      $colOrderTypeId INTEGER,
      $colOjolProvider TEXT,
      $colCategoryOrder TEXT,
      $colUserId INTEGER,
      $colCustomerId INTEGER,
      $colCustomerType TEXT,
      $colPaymentMethod TEXT,
      $colNumberTable INTEGER,
      $colDate TEXT NULL,
      $colNotes TEXT NULL,
      $colTotalAmount INTEGER,
      $colTotalQty INTEGER,
      $colPaidAmount INTEGER,
      $colChangeMoney INTEGER,
      $colIsPaid INTEGER NOT NULL DEFAULT 0,
      $colStatus TEXT NULL,
      $colCancelationOtp TEXT NULL,
      $colCancelationReason TEXT NULL,
      $colCreatedAt TEXT NULL,
      $colUpdatedAt TEXT NULL,
      $colDeletedAt TEXT NULL,
      $colSyncedAt TEXT NULL
    )
  ''';
}
