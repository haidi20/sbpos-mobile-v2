class SelectedPacketItem {
  final int productId;
  final int qty;

  const SelectedPacketItem({required this.productId, required this.qty});

  SelectedPacketItem copyWith({int? productId, int? qty}) {
    return SelectedPacketItem(
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toJson() => {'productId': productId, 'qty': qty};

  factory SelectedPacketItem.fromJson(Map<String, dynamic> json) {
    return SelectedPacketItem(
      productId: json['productId'] as int,
      qty: json['qty'] as int,
    );
  }

  @override
  String toString() => 'SelectedPacketItem(productId: $productId, qty: $qty)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedPacketItem &&
        other.productId == productId &&
        other.qty == qty;
  }

  @override
  int get hashCode => Object.hash(productId, qty);
}
