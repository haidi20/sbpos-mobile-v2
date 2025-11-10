import 'package:landing_page_menu/domain/entities/category_parent_entity.dart';

class CategoryParentModel {
  final int? id;
  final int? idServer;
  final String? name;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  CategoryParentModel({
    this.id,
    this.idServer,
    this.name,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  CategoryParentModel copyWith({
    int? id,
    int? idServer,
    String? name,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return CategoryParentModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory CategoryParentModel.fromJson(Map<String, dynamic> json) =>
      CategoryParentModel(
        id: json['id'],
        idServer: json['id_server'],
        name: json['name'],
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'])
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        syncedAt: json['synced_at'] != null ? DateTime.now() : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_server': idServer,
        'name': name,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  factory CategoryParentModel.fromEntity(CategoryParentEntity entity) {
    return CategoryParentModel(
      id: entity.id,
      name: entity.name,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Convert to entity
  CategoryParentEntity toEntity() => CategoryParentEntity(
        id: id,
        name: name,
        deletedAt: deletedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'name': name,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory CategoryParentModel.fromDbLocal(Map<String, dynamic> map) {
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

    return CategoryParentModel(
      id: toInt(map['id']),
      name: map['name'] as String?,
      deletedAt: toDate(map['deleted_at']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
    );
  }
}
