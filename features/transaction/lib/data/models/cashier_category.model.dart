import 'package:transaction/domain/entitties/cashier_category.entity.dart';

class CashierCategoryModel {
  final int? id;
  final String title;

  const CashierCategoryModel({
    this.id,
    required this.title,
  });

  factory CashierCategoryModel.fromJson(Map<String, dynamic> json) {
    return CashierCategoryModel(
      id: _toInt(json['id']),
      title: (json['title'] ?? json['name'] ?? json['label'] ?? '')
          .toString()
          .trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  CashierCategoryEntity toEntity() {
    return CashierCategoryEntity(
      id: id,
      title: title,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
