class CloseCashierStatusEntity {
  final bool canClose;
  final String message;
  final int pendingOrders;

  const CloseCashierStatusEntity({
    required this.canClose,
    this.message = '',
    this.pendingOrders = 0,
  });

  CloseCashierStatusEntity copyWith({
    bool? canClose,
    String? message,
    int? pendingOrders,
  }) {
    return CloseCashierStatusEntity(
      canClose: canClose ?? this.canClose,
      message: message ?? this.message,
      pendingOrders: pendingOrders ?? this.pendingOrders,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CloseCashierStatusEntity &&
        other.canClose == canClose &&
        other.message == message &&
        other.pendingOrders == pendingOrders;
  }

  @override
  int get hashCode => Object.hash(canClose, message, pendingOrders);
}
