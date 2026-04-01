class SettingTable {
  static const String tableName = 'settings';

  static const String colId = 'id';
  static const String colStoreName = 'store_name';
  static const String colBranch = 'branch';
  static const String colAddress = 'address';
  static const String colPhone = 'phone';
  static const String colPrinterAutoPrint = 'printer_auto_print';
  static const String colPrinterPrintLogo = 'printer_print_logo';
  static const String colPrinterPaperWidth = 'printer_paper_width';
  static const String colPrinterDevicesJson = 'printer_devices_json';
  static const String colPaymentMethodsJson = 'payment_methods_json';
  static const String colProfileName = 'profile_name';
  static const String colProfileEmployeeId = 'profile_employee_id';
  static const String colProfileEmail = 'profile_email';
  static const String colProfilePhone = 'profile_phone';
  static const String colNotificationPush = 'notification_push';
  static const String colNotificationTransactionSound =
      'notification_transaction_sound';
  static const String colNotificationStockAlert = 'notification_stock_alert';
  static const String colSecurityOldPin = 'security_old_pin';
  static const String colSecurityNewPin = 'security_new_pin';
  static const String colSecurityConfirmPin = 'security_confirm_pin';
  static const String colVersionLabel = 'version_label';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colStoreName TEXT,
      $colBranch TEXT,
      $colAddress TEXT,
      $colPhone TEXT,
      $colPrinterAutoPrint INTEGER,
      $colPrinterPrintLogo INTEGER,
      $colPrinterPaperWidth TEXT,
      $colPrinterDevicesJson TEXT,
      $colPaymentMethodsJson TEXT,
      $colProfileName TEXT,
      $colProfileEmployeeId TEXT,
      $colProfileEmail TEXT,
      $colProfilePhone TEXT,
      $colNotificationPush INTEGER,
      $colNotificationTransactionSound INTEGER,
      $colNotificationStockAlert INTEGER,
      $colSecurityOldPin TEXT,
      $colSecurityNewPin TEXT,
      $colSecurityConfirmPin TEXT,
      $colVersionLabel TEXT,
      $colUpdatedAt TEXT
    )
  ''';
}
