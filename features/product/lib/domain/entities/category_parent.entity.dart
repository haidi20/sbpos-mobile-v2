import 'package:product/data/models/category_parent.model.dart';

class CategoryParentEntity {
  final int? id;
  final int? idServer;
  final String? name;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  const CategoryParentEntity({
    this.id,
    this.idServer,
    this.name,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  CategoryParentEntity copyWith({
    int? id,
    int? idServer,
    String? name,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return CategoryParentEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory CategoryParentEntity.fromModel(CategoryParentModel model) {
    return CategoryParentEntity(
      id: model.id,
      idServer: model.idServer,
      name: model.name,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncedAt: model.syncedAt,
    );
  }

  CategoryParentModel toModel() {
    return CategoryParentModel(
      id: id,
      idServer: idServer,
      name: name,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryParentEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.name == name &&
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
        deletedAt,
        createdAt,
        updatedAt,
        syncedAt,
      );
}
