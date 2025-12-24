import 'package:core/core.dart';
import 'package:core/data/models/user_model.dart';
import 'package:core/data/datasources/db/auth_user.table.dart';
import 'package:core/utils/password_hash.dart';

class AuthUserQuery {
  final Database? database;
  final String _tblUsers = AuthUserTable.tableName;
  final _logger = Logger('AuthUserQuery');

  AuthUserQuery(this.database);

  Future<Map<String, dynamic>?> getUser() async {
    try {
      if (database != null) {
        final db = database;
        final List<Map<String, dynamic>> results = await db!.query(
          _tblUsers,
          limit: 1,
        );
        return results.isNotEmpty ? results.first : null;
      }

      // fallback to LocalDatabase (web/sembast)
      final list = await LocalDatabase.instance.getAll(_tblUsers);
      return list.isNotEmpty ? list.first : null;
    } catch (e) {
      _logger.severe("Error fetching user: $e");
      return null;
    }
  }

  Future<bool> authUser({
    required String email,
    required String password,
  }) async {
    try {
      if (database != null) {
        final db = database;
        final List<Map<String, dynamic>> results = await db!.query(
          _tblUsers,
          where: 'email = ?',
          whereArgs: [email],
        );
        if (results.isEmpty) return false;
        final storedHash = results.first['password'] as String?;
        if (storedHash == null) return false;
        final isValid = await PasswordHash.verify(password, storedHash);
        return isValid;
      }

      // fallback to LocalDatabase
      final list = await LocalDatabase.instance.getAll(_tblUsers);
      final found = list.firstWhere(
        (m) => (m['email'] ?? '') == email,
        orElse: () => {},
      );
      if (found.isEmpty) return false;
      final storedHash = found['password'] as String?;
      if (storedHash == null) return false;
      return await PasswordHash.verify(password, storedHash);
    } catch (e) {
      _logger.severe("Error authenticating user: $e");
      return false;
    }
  }

  Future<int> countUser() async {
    if (database != null) {
      final db = database;
      final result =
          await db!.rawQuery('SELECT COUNT(*) as total FROM $_tblUsers');
      return Sqflite.firstIntValue(result) ?? 0;
    }

    final list = await LocalDatabase.instance.getAll(_tblUsers);
    return list.length;
  }

  Future<int> storeUser(UserModel user) async {
    final userMap = await user.toLocalDbJson();
    if (database != null) {
      final db = database;
      await db!.delete(_tblUsers);
      return await db.insert(_tblUsers, userMap);
    }

    await LocalDatabase.instance.deleteAll(_tblUsers);
    return await LocalDatabase.instance.insert(_tblUsers, userMap);
  }

  Future<int> deleteUser() async {
    if (database != null) {
      final db = database;
      return await db!.delete(_tblUsers);
    }

    return await LocalDatabase.instance.deleteAll(_tblUsers);
  }

  Future<void> deleteToken() async {
    final getUserMap = await getUser();
    UserModel getuser = UserModel();
    if (getUserMap != null) {
      getuser = UserModel.fromMap(getUserMap);
    }

    if (database != null) {
      final db = database;
      await db!.update(
        _tblUsers,
        {'token': null},
        where: 'id = ?',
        whereArgs: [getuser.id],
      );
      return;
    }

    // For LocalDatabase (sembast) do a simple replace: delete all and re-insert without token
    if (getUserMap != null) {
      final modified = Map<String, dynamic>.from(getUserMap);
      modified['token'] = null;
      await LocalDatabase.instance.deleteAll(_tblUsers);
      await LocalDatabase.instance.insert(_tblUsers, modified);
    }
  }
}
