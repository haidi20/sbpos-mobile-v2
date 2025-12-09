// Response wrapper for transaction
import 'package:transaction/data/models/transaction.model.dart';

class TransactionResponse {
  final bool success;
  final String message;
  final List<TransactionModel>? data;

  TransactionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map(
              (item) => TransactionModel.fromJson(item as Map<String, dynamic>))
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
