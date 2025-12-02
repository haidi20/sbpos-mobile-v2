import 'package:core/core.dart';
import 'package:core/data/models/user_model.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

class AuthUserQuery {
  final Database? database;
  final String _tblUsers = 'users';
  final _logger = Logger('AuthUserQuery');

  AuthUserQuery(this.database);

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final db = database;
      final List<Map<String, dynamic>> results = await db!.query(
        _tblUsers,
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
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
      final db = database;
      final List<Map<String, dynamic>> results = await db!.query(
        _tblUsers,
        where: 'email = ?',
        whereArgs: [email],
      );
      if (results.isEmpty) return false;
      final storedHash = results.first['password'] as String?;
      if (storedHash == null) return false;
      final isValid = await FlutterBcrypt.verify(
        password: password,
        hash: storedHash,
      );
      return isValid;
    } catch (e) {
      _logger.severe("Error authenticating user: $e");
      return false;
    }
  }

  Future<int> countUser() async {
    final db = database;
    final result =
        await db!.rawQuery('SELECT COUNT(*) as total FROM $_tblUsers');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> storeUser(UserModel user) async {
    final db = database;
    await db!.delete(_tblUsers);
    final userMap = await user.toLocalDbJson();
    return await db.insert(_tblUsers, userMap);
  }

  Future<int> deleteUser() async {
    final db = database;
    return await db!.delete(_tblUsers);
  }

  Future<void> deleteToken() async {
    final db = database;
    final getUserMap = await getUser();
    UserModel getuser = UserModel();
    if (getUserMap != null) {
      getuser = UserModel.fromMap(getUserMap);
    }
    await db!.update(
      _tblUsers,
      {'token': null},
      where: 'id = ?',
      whereArgs: [getuser.id],
    );
  }
}
