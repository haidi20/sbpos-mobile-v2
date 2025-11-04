import 'package:core/data/models/user_model.dart';

class AuthResponse {
  UserModel? user;
  String? token;
  String? refreshToken;

  AuthResponse({
    this.user,
    this.token,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'] as String?;
    final userJson = json['user'] as Map<String, dynamic>?;

    UserModel? user;
    if (userJson != null) {
      // Buat salinan userJson agar tidak mengubah data asli
      final userMap = Map<String, dynamic>.from(userJson);
      // Masukkan access_token ke dalam userMap sebagai 'token'
      userMap['token'] = token;
      user = UserModel.fromJson(userMap);
    }

    return AuthResponse(
      user: user,
      token: token,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'access_token': token,
      'refresh_token': refreshToken,
    };
  }

  @override
  String toString() {
    return 'AuthResponse('
        'user: $user, '
        'token: $token, '
        'refreshToken: $refreshToken)';
  }
}
