class OperationalCheckResponse {
  final bool success;
  final bool isAllowed;
  final String message;

  const OperationalCheckResponse({
    required this.success,
    required this.isAllowed,
    required this.message,
  });

  factory OperationalCheckResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map<String, dynamic> ? data : null;

    final isAllowed = _toBool(
          dataMap?['is_allowed'] ??
              dataMap?['isAllowed'] ??
              dataMap?['active'] ??
              dataMap?['is_active'] ??
              dataMap?['valid'] ??
              dataMap?['is_valid'] ??
              dataMap?['service_available'] ??
              dataMap?['subscription_active'] ??
              dataMap?['status'] ??
              data,
        ) ??
        false;

    return OperationalCheckResponse(
      success: _toBool(json['success']) ?? true,
      isAllowed: isAllowed,
      message: (json['message'] ??
              dataMap?['message'] ??
              dataMap?['note'] ??
              '')
          .toString(),
    );
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}
