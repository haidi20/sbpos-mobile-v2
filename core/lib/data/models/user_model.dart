import 'package:core/domain/entities/user_entity.dart';
import 'package:core/utils/password_hash.dart';

class UserModel {
  final int? id;
  final String? username;
  final String? password;
  final String? email;
  final String? token;
  final String? refreshToken;
  final int? roleId;
  final int? outletId;
  final bool? isActive;
  final DateTime? lastLogin;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.password,
    this.token,
    this.refreshToken,
    this.roleId,
    this.outletId,
    this.isActive,
    this.lastLogin,
  });

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? token,
    String? refreshToken,
    int? roleId,
    int? outletId,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      roleId: roleId ?? this.roleId,
      outletId: outletId ?? this.outletId,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  factory UserModel.fromLoginResponse(Map<String, dynamic> userJson) {
    return UserModel(
      id: _asInt(userJson['id'] ?? userJson['id_petugas']),
      username: (userJson['name'] ?? userJson['username']) as String?,
      token: userJson['token'] as String? ?? userJson['access_token'] as String?,
      refreshToken: userJson['refresh_token'] as String?,
      roleId: _asInt(userJson['role_id']),
      outletId: _asInt(userJson['outlet_id']) ?? _asInt(userJson['warehouse_id']),
      isActive: _asBool(userJson['is_active']),
      email: userJson['email'] as String?,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asInt(json['id']),
      username: (json['username'] ?? json['name']) as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      roleId: _asInt(json['role_id']),
      outletId: _asInt(json['outlet_id']) ?? _asInt(json['warehouse_id']),
      isActive: _asBool(json['is_active']),
      email: json['email'] as String?,
      lastLogin: _asDate(json['last_login']),
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
      hashedPassword = alreadyHashed ? p : await PasswordHash.hashPassword(p);
    }

    return {
      'id': id,
      'username': username,
      'email': email,
      'password': hashedPassword,
      'token': token,
      'refresh_token': refreshToken,
      'role_id': roleId,
      'warehouse_id': outletId,
      'outlet_id': outletId,
      'is_active': isActive == null ? null : (isActive! ? 1 : 0),
      'last_login': (lastLogin ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'token': token,
      'refresh_token': refreshToken,
      'role_id': roleId,
      'warehouse_id': outletId,
      'outlet_id': outletId,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      password: entity.password,
      email: entity.email,
      token: entity.token,
      refreshToken: entity.refreshToken,
      roleId: entity.roleId,
      outletId: entity.outletId,
      isActive: entity.isActive,
      lastLogin: entity.lastLogin,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      password: password,
      email: email,
      token: token,
      refreshToken: refreshToken,
      roleId: roleId,
      outletId: outletId,
      isActive: isActive,
      lastLogin: lastLogin,
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value == '1') return true;
      if (value == '0') return false;
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final epoch = int.tryParse(value);
      if (epoch != null) {
        return DateTime.fromMillisecondsSinceEpoch(epoch);
      }
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<String?> getHashedPassword() async {
    if (password != null && password!.isNotEmpty) {
      final alreadyHashed = password!.startsWith(r'$2a$') ||
          password!.startsWith(r'$2b$') ||
          password!.startsWith(r'$2y$');
      if (alreadyHashed) {
        return password;
      }
      return await PasswordHash.hashPassword(password!);
    }
    return null;
  }
}
