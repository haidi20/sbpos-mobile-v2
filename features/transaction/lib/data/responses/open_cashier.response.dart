import 'package:transaction/data/models/shift.model.dart';

class OpenCashierResponseModel {
  final bool success;
  final String message;
  final ShiftModel? shift;

  const OpenCashierResponseModel({
    required this.success,
    required this.message,
    this.shift,
  });

  factory OpenCashierResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    ShiftModel? shift;

    if (data is Map<String, dynamic>) {
      if (data['shift'] is Map<String, dynamic>) {
        shift = ShiftModel.fromJson(data['shift'] as Map<String, dynamic>);
      } else if (_looksLikeShift(data)) {
        shift = ShiftModel.fromJson(data);
      }
    }

    return OpenCashierResponseModel(
      success: _toBool(json['success']) ?? true,
      message: (json['message'] ?? '').toString(),
      shift: shift,
    );
  }

  static bool _looksLikeShift(Map<String, dynamic> json) {
    return json.containsKey('id') ||
        json.containsKey('shift_number') ||
        json.containsKey('opening_balance');
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed != 0;
    }
    return null;
  }
}
