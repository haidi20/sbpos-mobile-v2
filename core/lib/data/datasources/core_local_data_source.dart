import 'package:core/data/models/user_model.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:core/utils/helpers/base_error_helper.dart';

class CoreLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();

  Future<UserModel?> getUser() async {
    final result = await databaseHelper.getUser();

    if (result != null) {
      return UserModel.fromMap(result);
    } else {
      return null;
    }
  }

  Future<bool> authenticationUser(
      {required String email, required String password}) async {
    try {
      return await databaseHelper.authUser(
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
      return await databaseHelper.countUser();
    } catch (e) {
      throw Exception(
          'Gagal mendapatkan data user di lokal db: ${e.toString()}');
    }
  }

  Future<String> storeUser({required UserModel user}) async {
    try {
      // print(user.toString());
      await databaseHelper.storeUser(user);

      return 'Berhasil memperbaharui data user di lokal db';
    } catch (e) {
      throw Exception(
          'Gagal memperbaharui data user di lokal db: ${e.toString()}');
    }
  }

  Future<void> deleteUser() async {
    try {
      await databaseHelper.deleteUser();
      print('Berhasil delete user di lokal db');
    } catch (e) {
      throw Exception('Gagal delete user di lokal db: ${e.toString()}');
    }
  }

  Future<void> deleteToken() async {
    try {
      // print(user.toString());
      databaseHelper.deleteToken();

      print('Berhasil delete token user di lokal db');
    } catch (e) {
      throw Exception('Gagal delete token user di lokal db: ${e.toString()}');
    }
  }
}
