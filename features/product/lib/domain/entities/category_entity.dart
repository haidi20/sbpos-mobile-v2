import 'package:product/data/models/category_model.dart';

class CategoryEntity {
  final int? id;
  final int? idServer;
  final String? name;
  final int? categoryParentsId;
  final int? businessId;
  final bool? isActive;
  final double? value;
  final int? color;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  const CategoryEntity({
    this.id,
    this.idServer,
    this.name,
    this.value,
    this.color,
    this.categoryParentsId,
    this.businessId,
    this.isActive,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  CategoryEntity copyWith({
    int? id,
    int? idServer,
    String? name,
    int? categoryParentsId,
    int? businessId,
    double? value,
    int? color,
    bool? isActive,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      categoryParentsId: categoryParentsId ?? this.categoryParentsId,
      businessId: businessId ?? this.businessId,
      value: value ?? this.value,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory CategoryEntity.fromModel(CategoryModel model) {
    return CategoryEntity(
      id: model.id,
      idServer: model.idServer,
      name: model.name,
      categoryParentsId: model.categoryParentsId,
      businessId: model.businessId,
      isActive: model.isActive,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncedAt: model.syncedAt,
    );
  }

  CategoryModel toModel() {
    return CategoryModel(
      id: id,
      idServer: idServer,
      name: name,
      categoryParentsId: categoryParentsId,
      businessId: businessId,
      isActive: isActive,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.name == name &&
        other.categoryParentsId == categoryParentsId &&
        other.businessId == businessId &&
        other.isActive == isActive &&
        other.value == value &&
        other.color == color &&
        other.deletedAt == deletedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.syncedAt == syncedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        idServer,
        name,
        value,
        color,
        categoryParentsId,
        businessId,
        isActive,
        deletedAt,
        createdAt,
        updatedAt,
        syncedAt,
      );
}
