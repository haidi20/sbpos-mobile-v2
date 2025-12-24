import 'package:bcrypt/bcrypt.dart';

/// Implementasi native menggunakan `bcrypt` murni-Dart untuk API yang konsisten.
class PasswordHash {
  static Future<String> hashPassword(String password, {String? salt}) async {
    final gensalt = salt ?? BCrypt.gensalt();
    final hashed = BCrypt.hashpw(password, gensalt);
    return hashed;
  }

  static Future<bool> verify(String password, String hashed) async {
    return BCrypt.checkpw(password, hashed);
  }
}
