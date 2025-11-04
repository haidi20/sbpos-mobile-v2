import 'package:core/domain/entities/user_entity.dart';

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

  /// Untuk menyimpan ke database lokal (tanpa password)
  Map<String, dynamic> toLocalDbJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token, // password sengaja dikecualikan
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
}
