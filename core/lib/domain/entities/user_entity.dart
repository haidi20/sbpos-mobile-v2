import 'package:core/data/models/user_model.dart';

class UserEntity {
  final int? id;
  final String? username;
  final String? email;
  final String? password;
  final String? token;
  final String? refreshToken;
  final int? roleId;
  final int? warehouseId;
  final bool? isActive;
  final DateTime? lastLogin;

  const UserEntity({
    this.id,
    this.username,
    this.password,
    this.email,
    this.token,
    this.refreshToken,
    this.roleId,
    this.warehouseId,
    this.isActive,
    this.lastLogin,
  });

  UserEntity copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? token,
    String? refreshToken,
    int? roleId,
    int? warehouseId,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      roleId: roleId ?? this.roleId,
      warehouseId: warehouseId ?? this.warehouseId,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  factory UserEntity.fromModel(UserModel model) {
    return UserEntity(
      id: model.id,
      username: model.username,
      password: model.password,
      email: model.email,
      token: model.token,
      refreshToken: model.refreshToken,
      roleId: model.roleId,
      warehouseId: model.warehouseId,
      isActive: model.isActive,
      lastLogin: model.lastLogin,
    );
  }

  UserModel toModel() {
    return UserModel(
      id: id,
      username: username,
      password: password,
      email: email,
      token: token,
      refreshToken: refreshToken,
      roleId: roleId,
      warehouseId: warehouseId,
      isActive: isActive,
      lastLogin: lastLogin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.token == token &&
        other.refreshToken == refreshToken &&
        other.roleId == roleId &&
        other.warehouseId == warehouseId &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        token.hashCode ^
        refreshToken.hashCode ^
        roleId.hashCode ^
        warehouseId.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return '''
      UserEntity(
        id: $id,
        username: $username,
        email: $email,
        token: $token,
        refreshToken: $refreshToken,
        roleId: $roleId,
        warehouseId: $warehouseId,
        isActive: $isActive
      )''';
  }
}
