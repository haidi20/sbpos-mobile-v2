class AuthUserTable {
  // 1. Table name constant
  static const String tableName = 'auth_users';

  // 2. Column name constants
  static const String colId = 'id';
  static const String colUsername = 'username';
  static const String colPassword = 'password';
  static const String colToken = 'token';
  static const String colEmail = 'email';

  // 3. Table creation query (DDL)
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $colId INTEGER PRIMARY KEY,
      $colUsername TEXT,
      $colPassword TEXT,
      $colToken TEXT,
      $colEmail TEXT UNIQUE
    )
  ''';
}
