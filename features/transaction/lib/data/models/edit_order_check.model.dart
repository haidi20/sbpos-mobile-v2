import 'package:transaction/data/models/transaction.model.dart';

class EditOrderCheckModel {
  final bool canEdit;
  final String message;
  final TransactionModel? transaction;

  const EditOrderCheckModel({
    required this.canEdit,
    required this.message,
    this.transaction,
  });

  factory EditOrderCheckModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    TransactionModel? transaction;
    var canEdit = _toBool(json['success']) ?? false;
    var message = (json['message'] ?? '').toString();

    if (data is Map<String, dynamic>) {
      canEdit = _toBool(data['can_edit']) ??
          _toBool(data['canEdit']) ??
          canEdit;
      if (message.isEmpty) {
        message = (data['message'] ?? data['status_message'] ?? '').toString();
      }

      final transactionJson = data['transaction'];
      if (transactionJson is Map<String, dynamic>) {
        transaction = TransactionModel.fromJson(transactionJson);
      } else if (_looksLikeTransaction(data)) {
        transaction = TransactionModel.fromJson(data);
      }
    }

    return EditOrderCheckModel(
      canEdit: canEdit,
      message: message,
      transaction: transaction,
    );
  }

  static bool _looksLikeTransaction(Map<String, dynamic> json) {
    return json.containsKey('order_type_id') ||
        json.containsKey('sequence_number') ||
        json.containsKey('total_amount');
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
