import 'package:core/data/models/user_model.dart';

class UserEntity {
  final int? id;
  final String? username;
  final String? email;
  final String? password;
  final String? token;

  const UserEntity({
    this.id,
    this.username,
    this.password,
    this.email,
    this.token,
  });

  UserEntity copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  factory UserEntity.fromModel(UserModel model) {
    return UserEntity(
      id: model.id,
      username: model.username,
      password: model.password,
      email: model.email,
      token: model.token,
    );
  }

  UserModel toModel() {
    return UserModel(
      id: id,
      username: username,
      password: password,
      email: email,
      token: token,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.token == token;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ email.hashCode ^ token.hashCode;
  }

  @override
  String toString() {
    return '''
      UserEntity(
        id: $id,
        username: $username,
        email: $email,
        token: $token
      )''';
  }
}
