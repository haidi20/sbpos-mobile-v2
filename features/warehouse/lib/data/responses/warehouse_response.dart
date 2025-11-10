// Response wrapper for warehouse
import 'package:warehouse/data/models/warehouse_model.dart';

class WarehouseResponse {
  final bool success;
  final String message;
  final List<WarehouseModel>? data;

  WarehouseResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory WarehouseResponse.fromJson(Map<String, dynamic> json) {
    return WarehouseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => WarehouseModel.fromJson(item as Map<String, dynamic>))
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
