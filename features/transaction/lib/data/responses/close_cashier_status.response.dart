class CloseCashierStatusResponseModel {
  final bool success;
  final String message;
  final bool canClose;
  final int pendingOrders;

  const CloseCashierStatusResponseModel({
    required this.success,
    required this.message,
    required this.canClose,
    required this.pendingOrders,
  });

  factory CloseCashierStatusResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];
    bool canClose = false;
    int pendingOrders = 0;

    if (data is bool) {
      canClose = data;
    } else if (data is Map<String, dynamic>) {
      canClose = _toBool(data['can_close']) ??
          _toBool(data['closable']) ??
          _toBool(data['canClose']) ??
          false;
      pendingOrders = _toInt(data['pending_orders']) ??
          _toInt(data['pending_count']) ??
          _toInt(data['pendingOrders']) ??
          0;
    }

    return CloseCashierStatusResponseModel(
      success: _toBool(json['success']) ?? true,
      message: (json['message'] ?? '').toString(),
      canClose: canClose,
      pendingOrders: pendingOrders,
    );
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

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
