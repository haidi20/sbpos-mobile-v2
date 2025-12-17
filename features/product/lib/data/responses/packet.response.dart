import 'package:product/data/models/packet.model.dart';

class PacketResponse {
  final bool success;
  final String message;
  final List<PacketModel>? data;

  PacketResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PacketResponse.fromJson(Map<String, dynamic> json) {
    return PacketResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => PacketModel.fromJson(item as Map<String, dynamic>))
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
