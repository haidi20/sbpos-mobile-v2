import 'package:core/domain/entities/user_entity.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

class UserModel {
  final int? id;
  final String? username;
  final String? password; // biasanya hanya untuk request, tidak disimpan
  final String? email;
  final String? token;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.password,
    this.token,
  });

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  /// Factory untuk parsing dari respons login
  factory UserModel.fromLoginResponse(Map<String, dynamic> userJson) {
    return UserModel(
      id: _asInt(userJson['id_petugas']),
      username: userJson['username'] as String?,
      token: userJson['token'] as String?,
      email: userJson['email'] as String?,
      // password tidak ada di respons login → biarkan null
    );
  }

  /// Untuk parsing dari database lokal atau cache
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asInt(json['id']),
      username: json['username'] as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
      email: json['email'] as String?,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) =>
      UserModel.fromJson(map);

  Future<Map<String, dynamic>> toLocalDbJson() async {
    String? hashedPassword;

    if (password != null && password!.isNotEmpty) {
      final p = password!;
      final alreadyHashed = p.startsWith(r'$2a$') ||
          p.startsWith(r'$2b$') ||
          p.startsWith(r'$2y$');
      if (alreadyHashed) {
        hashedPassword = p;
      } else {
        final salt = await FlutterBcrypt.saltWithRounds(rounds: 12);
        hashedPassword = await FlutterBcrypt.hashPw(password: p, salt: salt);
      }
    }

    return {
      'id': id,
      'username': username,
      'email': email,
      'password': hashedPassword, // hashed, never plain text
      'token': token,
    };
  }

  /// Untuk keperluan request (misal: register, update profil)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'token': token,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      password: entity.password,
      email: entity.email,
      token: entity.token,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      password: password,
      email: email,
      token: token,
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<String?> getHashedPassword() async {
    if (password != null && password!.isNotEmpty) {
      final alreadyHashed = password!.startsWith(r'$2a$') ||
          password!.startsWith(r'$2b$') ||
          password!.startsWith(r'$2y$');
      if (alreadyHashed) {
        return password;
      } else {
        final salt = await FlutterBcrypt.saltWithRounds(rounds: 12);
        return await FlutterBcrypt.hashPw(password: password!, salt: salt);
      }
    }
    return null;
  }
}
