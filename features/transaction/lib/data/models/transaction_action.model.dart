import 'package:transaction/domain/entitties/transaction_action.entity.dart';

class TransactionActionModel {
  final bool success;
  final String message;

  const TransactionActionModel({
    required this.success,
    required this.message,
  });

  factory TransactionActionModel.fromJson(Map<String, dynamic> json) {
    return TransactionActionModel(
      success: _toBool(json['success']) ??
          _toBool(json['status']) ??
          _toBool(json['data']) ??
          false,
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }

  TransactionActionEntity toEntity() {
    return TransactionActionEntity(
      success: success,
      message: message,
    );
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value == '1') return true;
      if (value == '0') return false;
      return value.toLowerCase() == 'true';
    }
    return null;
  }
}
