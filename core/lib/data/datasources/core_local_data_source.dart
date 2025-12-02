import 'package:core/core.dart';
import 'package:core/data/models/user_model.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:core/data/datasources/db/auth_user.query.dart';

class CoreLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final _logger = Logger('CoreLocalDataSource');

  Future<UserModel?> getUser() async {
    final db = await databaseHelper.database;
    final authQuery = AuthUserQuery(db);
    final result = await authQuery.getUser();

    if (result != null) {
      return UserModel.fromMap(result);
    }
    return null;
  }

  Future<bool> authenticationUser({
    required String email,
    required String password,
  }) async {
    try {
      final db = await databaseHelper.database;
      final authQuery = AuthUserQuery(db);
      return await authQuery.authUser(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(
          'Gagal mendapatkan token user di lokal db: ${e.toString()}');
    }
  }

  Future<int> countUser() async {
    try {
      // print(user.toString());
      final db = await databaseHelper.database;
      final authQuery = AuthUserQuery(db);
      return await authQuery.countUser();
    } catch (e) {
      throw Exception(
          'Gagal mendapatkan data user di lokal db: ${e.toString()}');
    }
  }

  Future<String> storeUser({
    required UserModel user,
  }) async {
    try {
      // print(user.toString());
      final db = await databaseHelper.database;
      final authQuery = AuthUserQuery(db);
      await authQuery.storeUser(user);

      return 'Berhasil memperbaharui data user di lokal db';
    } catch (e) {
      throw Exception(
          'Gagal memperbaharui data user di lokal db: ${e.toString()}');
    }
  }

  Future<void> deleteUser() async {
    try {
      final db = await databaseHelper.database;
      final authQuery = AuthUserQuery(db);
      await authQuery.deleteUser();
      _logger.info('Berhasil delete user di lokal db');
    } catch (e) {
      throw Exception('Gagal delete user di lokal db: ${e.toString()}');
    }
  }

  Future<void> deleteToken() async {
    try {
      // print(user.toString());
      final db = await databaseHelper.database;
      final authQuery = AuthUserQuery(db);
      await authQuery.deleteToken();

      _logger.info('Berhasil delete token user di lokal db');
    } catch (e) {
      throw Exception('Gagal delete token user di lokal db: ${e.toString()}');
    }
  }
}
