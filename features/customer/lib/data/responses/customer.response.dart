import 'package:customer/data/models/customer.model.dart';

class CustomerResponse {
  final bool success;
  final String message;
  final List<CustomerModel>? data;

  CustomerResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => CustomerModel.fromJson(item as Map<String, dynamic>))
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
