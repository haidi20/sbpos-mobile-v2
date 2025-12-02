enum CartStatus {
  paid('lunas'),
  pending('pending'),
  cancelled('batal');

  final String value;
  const CartStatus(this.value);

  static CartStatus? fromString(String? status) {
    if (status == null) return null;
    return CartStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == status.toLowerCase(),
      orElse: () => CartStatus.pending,
    );
  }

  static String? toStringValue(CartStatus? status) {
    return status?.value;
  }
}

class CartModel {
  final int? id;
  final int? idServer;
  final int? productId;
  final int? qty;
  final String? note;
  final double? price;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  CartModel({
    this.id,
    this.idServer,
    this.productId,
    this.qty,
    this.note,
    this.price,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  CartModel copyWith({
    int? id,
    int? idServer,
    int? productId,
    int? qty,
    String? note,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      note: note ?? this.note,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        idServer: json['id'],
        productId: json['product_id'],
        qty: json['qty'],
        note: json['note'],
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        syncedAt: json['synced_at'] != null
            ? DateTime.parse(json['synced_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_server': idServer,
        'product_id': productId,
        'qty': qty,
        'note': note,
        'price': price,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer,
        'product_id': productId,
        'qty': qty,
        'note': note,
        'price': price,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  factory CartModel.fromDbLocal(Map<String, dynamic> map) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return CartModel(
      id: toInt(map['id']),
      idServer: toInt(map['id_server']),
      productId: toInt(map['product_id']),
      qty: toInt(map['qty']),
      note: map['note'] as String?,
      price: toDouble(map['price']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      syncedAt: toDate(map['synced_at']),
    );
  }
}
