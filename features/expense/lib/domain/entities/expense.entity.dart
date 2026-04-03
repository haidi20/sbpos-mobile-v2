class ExpenseEntity {
  final int? id;
  final int? categoryId;
  final String? categoryName;
  final int? qty;
  final int? totalAmount;
  final String? notes;
  final DateTime? createdAt;

  const ExpenseEntity({
    this.id,
    this.categoryId,
    this.categoryName,
    this.qty,
    this.totalAmount,
    this.notes,
    this.createdAt,
  });

  ExpenseEntity copyWith({
    int? id,
    int? categoryId,
    String? categoryName,
    int? qty,
    int? totalAmount,
    String? notes,
    DateTime? createdAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      qty: qty ?? this.qty,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
