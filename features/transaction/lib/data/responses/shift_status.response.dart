import 'package:transaction/data/models/shift.model.dart';

class ShiftStatusResponseModel {
  final bool success;
  final String message;
  final bool isOpen;
  final ShiftModel? shift;

  const ShiftStatusResponseModel({
    required this.success,
    required this.message,
    required this.isOpen,
    this.shift,
  });

  factory ShiftStatusResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final bool isOpen;
    ShiftModel? shift;

    if (data is bool) {
      isOpen = data;
    } else if (data is Map<String, dynamic>) {
      isOpen = _toBool(data['is_open']) ??
          _toBool(data['isOpen']) ??
          _toBool(json['is_open']) ??
          false;

      final shiftJson = data['shift'];
      if (shiftJson is Map<String, dynamic>) {
        shift = ShiftModel.fromJson(shiftJson);
      } else if (_looksLikeShift(data)) {
        shift = ShiftModel.fromJson(data);
      }
    } else {
      isOpen = _toBool(json['is_open']) ?? false;
    }

    return ShiftStatusResponseModel(
      success: _toBool(json['success']) ?? true,
      message: (json['message'] ?? '').toString(),
      isOpen: isOpen,
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
