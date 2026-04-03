import 'package:transaction/data/models/cashier_category.model.dart';

class CashierCategoryEntity {
  final int? id;
  final String title;

  const CashierCategoryEntity({
    this.id,
    required this.title,
  });

  CashierCategoryEntity copyWith({
    int? id,
    String? title,
  }) {
    return CashierCategoryEntity(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  factory CashierCategoryEntity.fromModel(CashierCategoryModel model) {
    return CashierCategoryEntity(
      id: model.id,
      title: model.title,
    );
  }

  CashierCategoryModel toModel() {
    return CashierCategoryModel(
      id: id,
      title: title,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CashierCategoryEntity &&
        other.id == id &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(id, title);
}
