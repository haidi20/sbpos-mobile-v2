import 'package:product/data/models/product_model.dart';

class LandingPageMenuResponse {
  final bool success;
  final String message;
  final List<ProductModel>? data;

  LandingPageMenuResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LandingPageMenuResponse.fromJson(Map<String, dynamic> json) {
    return LandingPageMenuResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => ProductModel.fromJson(item))
              .toList()
          : null,
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
