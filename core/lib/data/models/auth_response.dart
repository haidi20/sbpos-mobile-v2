import 'package:core/data/models/user_model.dart';

class AuthResponse {
  bool? success;
  String? message;
  AuthDataResponse? data;
  DateTime? timestamp;

  AuthResponse({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return AuthResponse(
      success: json['succes'] as bool?, // tetap sesuai typo API
      message: json['message'] as String?,
      data: data != null ? AuthDataResponse.fromJson(data) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'succes': success,
      'message': message,
      'data': data?.toJson(),
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AuthResponse('
        'success: $success, '
        'message: $message, '
        'data: $data, '
        'timestamp: $timestamp)';
  }
}

class AuthDataResponse {
  UserModel? user;
  String? token;

  AuthDataResponse({this.user, this.token});

  factory AuthDataResponse.fromJson(Map<String, dynamic> json) {
    return AuthDataResponse(
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
    };
  }

  @override
  String toString() {
    return 'AuthDataResponse(user: $user, token: $token)';
  }
}
