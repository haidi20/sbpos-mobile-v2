class AuthUserTable {
  static const String tableName = 'auth_users';

  static const String colId = 'id';
  static const String colUsername = 'username';
  static const String colPassword = 'password';
  static const String colToken = 'token';
  static const String colRefreshToken = 'refresh_token';
  static const String colEmail = 'email';
  static const String colRoleId = 'role_id';
  static const String colWarehouseId = 'warehouse_id';
  static const String colOutletId = 'outlet_id';
  static const String colIsActive = 'is_active';
  static const String colLastLogin = 'last_login';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colUsername TEXT,
      $colPassword TEXT,
      $colToken TEXT,
      $colRefreshToken TEXT,
      $colEmail TEXT UNIQUE,
      $colRoleId INTEGER,
      $colWarehouseId INTEGER,
      $colOutletId INTEGER,
      $colIsActive INTEGER,
      $colLastLogin INTEGER
    )
  ''';

  static const String createIndexUsername =
      'CREATE INDEX IF NOT EXISTS idx_auth_username ON $tableName($colUsername)';
}
