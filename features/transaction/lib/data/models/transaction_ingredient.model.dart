class TransactionIngredientModel {
  final int? id;
  final int? outletId;
  final int? transactionId;
  final int? ingredientId;
  final int? productId;
  final DateTime? date;
  final int? qtySold;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  TransactionIngredientModel({
    this.id,
    this.outletId,
    this.transactionId,
    this.ingredientId,
    this.productId,
    this.date,
    this.qtySold,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  TransactionIngredientModel copyWith({
    int? id,
    int? outletId,
    int? transactionId,
    int? ingredientId,
    int? productId,
    DateTime? date,
    int? qtySold,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TransactionIngredientModel(
      id: id ?? this.id,
      outletId: outletId ?? this.outletId,
      transactionId: transactionId ?? this.transactionId,
      ingredientId: ingredientId ?? this.ingredientId,
      productId: productId ?? this.productId,
      date: date ?? this.date,
      qtySold: qtySold ?? this.qtySold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory TransactionIngredientModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    return TransactionIngredientModel(
      id: toInt(json['id']),
      outletId: toInt(json['outlet_id']),
      transactionId: toInt(json['transaction_id']),
      ingredientId: toInt(json['ingredient_id']),
      productId: toInt(json['product_id']),
      date: parseDate(json['date']),
      qtySold: toInt(json['qty_sold']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      deletedAt: parseDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'outlet_id': outletId,
        'transaction_id': transactionId,
        'ingredient_id': ingredientId,
        'product_id': productId,
        'date': date?.toIso8601String(),
        'qty_sold': qtySold,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'outlet_id': outletId,
        'transaction_id': transactionId,
        'ingredient_id': ingredientId,
        'product_id': productId,
        'date': date?.toIso8601String(),
        'qty_sold': qtySold,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  factory TransactionIngredientModel.fromDbLocal(Map<String, dynamic> map) {
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

    return TransactionIngredientModel(
      id: toInt(map['id']),
      outletId: toInt(map['outlet_id']),
      transactionId: toInt(map['transaction_id']),
      ingredientId: toInt(map['ingredient_id']),
      productId: toInt(map['product_id']),
      date: toDate(map['date']),
      qtySold: toInt(map['qty_sold']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      deletedAt: toDate(map['deleted_at']),
    );
  }
}
