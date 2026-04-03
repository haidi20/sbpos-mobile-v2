import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:core/data/datasources/db/auth_user.dao.dart';
import 'package:core/data/models/user_model.dart';

class CoreLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final _logger = Logger('CoreLocalDataSource');

  Future<UserModel?> getUser() async {
    final db = await databaseHelper.database;
    final authDao = AuthUserDao(db);
    final result = await authDao.getUser();

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
      final authDao = AuthUserDao(db);
      return await authDao.authUser(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(
        'Gagal mendapatkan token user di lokal db: ${e.toString()}',
      );
    }
  }

  Future<int> countUser() async {
    try {
      final db = await databaseHelper.database;
      final authDao = AuthUserDao(db);
      return await authDao.countUser();
    } catch (e) {
      throw Exception(
        'Gagal mendapatkan data user di lokal db: ${e.toString()}',
      );
    }
  }

  Future<String> storeUser({
    required UserModel user,
  }) async {
    try {
      final db = await databaseHelper.database;
      final authDao = AuthUserDao(db);
      await authDao.storeUser(user);

      return 'Berhasil memperbaharui data user di lokal db';
    } catch (e) {
      throw Exception(
        'Gagal memperbaharui data user di lokal db: ${e.toString()}',
      );
    }
  }

  Future<String> updateUserSession({
    required String accessToken,
    String? refreshToken,
    DateTime? lastLogin,
  }) async {
    final currentUser = await getUser();
    if (currentUser == null) {
      throw Exception('Tidak ada user lokal untuk diperbarui');
    }

    final updatedUser = currentUser.copyWith(
      token: accessToken,
      refreshToken: refreshToken ?? currentUser.refreshToken,
      lastLogin: lastLogin ?? DateTime.now(),
    );

    return storeUser(user: updatedUser);
  }

  Future<void> deleteUser() async {
    try {
      final db = await databaseHelper.database;
      final authDao = AuthUserDao(db);
      await authDao.deleteUser();
      _logger.info('Berhasil delete user di lokal db');
    } catch (e) {
      throw Exception('Gagal delete user di lokal db: ${e.toString()}');
    }
  }

  Future<void> deleteToken() async {
    try {
      final db = await databaseHelper.database;
      final authDao = AuthUserDao(db);
      await authDao.deleteToken();

      _logger.info('Berhasil delete token user di lokal db');
    } catch (e) {
      throw Exception('Gagal delete token user di lokal db: ${e.toString()}');
    }
  }
}
