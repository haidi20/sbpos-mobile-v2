import 'package:expense/data/models/expense.model.dart';

class ExpenseResponse {
  final bool success;
  final String message;
  final List<ExpenseModel>? data;

  ExpenseResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
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
