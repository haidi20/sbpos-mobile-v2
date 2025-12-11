import '../models/outlet.model.dart';

class OutletResponse {
  final bool success;
  final String message;
  final List<OutletModel>? data;

  OutletResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OutletResponse.fromJson(Map<String, dynamic> json) {
    return OutletResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => OutletModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}
