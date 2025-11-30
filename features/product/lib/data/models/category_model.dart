// Model for category from API
import 'package:product/domain/entities/category_entity.dart';

class CategoryModel {
  final int? id;
  final int? idServer; // Added
  final String? name;
  // Optional field for UI/chart value (percentage or absolute) used by report/dashboard
  final double? value;
  // Optional color stored as ARGB integer (use Color(value) when rendering)
  final int? color;
  final int? categoryParentsId;
  final int? businessId;
  final bool? isActive;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt; // Added

  CategoryModel({
    this.id,
    this.idServer, // Added
    this.name,
    this.value,
    this.color,
    this.categoryParentsId,
    this.businessId,
    this.isActive,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt, // Added
  });

  CategoryModel copyWith({
    int? id,
    int? idServer, // Added
    String? name,
    double? value,
    int? color,
    int? categoryParentsId,
    int? businessId,
    bool? isActive,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt, // Added
  }) {
    return CategoryModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer, // Added
      name: name ?? this.name,
      value: value ?? this.value,
      color: color ?? this.color,
      categoryParentsId: categoryParentsId ?? this.categoryParentsId,
      businessId: businessId ?? this.businessId,
      isActive: isActive ?? this.isActive,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt, // Added
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'],
        idServer: json['id_server'], // Added
        name: json['name'],
        value: _toDouble(json['value']),
        color: _toColorInt(json['color']),
        categoryParentsId: json['category_parents_id'],
        businessId: json['business_id'],
        isActive: _toBool(json['is_active']),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'])
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        syncedAt: json['synced_at'] != null // Added
            ? DateTime.parse(json['synced_at'])
            : null,
      );

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _toColorInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) {
      // Accept hex string like '#FF00FF' or '0xFF00FF'
      final s = v.replaceAll('#', '').replaceAll('0x', '');
      final parsed = int.tryParse(s, radix: 16);
      if (parsed != null) {
        // If provided without alpha (6 digits), assume opaque
        if (s.length == 6) return 0xFF000000 | parsed;
        return parsed;
      }
    }
    return null;
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value == '1') return true;
      if (value == '0') return false;
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_server': idServer, // Added
        'name': name,
        'value': value,
        'color': color,
        'category_parents_id': categoryParentsId,
        'business_id': businessId,
        'is_active': isActive,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(), // Added
      };

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      idServer: entity.idServer, // Added, make sure CategoryEntity has idServer
      name: entity.name,
      // value/color are UI-only, not available on entity by default
      value: null,
      color: null,
      categoryParentsId: entity.categoryParentsId,
      businessId: entity.businessId,
      isActive: entity.isActive,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncedAt: entity.syncedAt, // Added, make sure CategoryEntity has syncedAt
    );
  }

  // Convert to entity
  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        idServer: idServer, // Added, make sure CategoryEntity has idServer
        name: name,
        categoryParentsId: categoryParentsId,
        businessId: businessId,
        isActive: isActive ?? false,
        deletedAt: deletedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncedAt: syncedAt, // Added, make sure CategoryEntity has syncedAt
      );

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer, // Added
        'name': name,
        'value': value,
        'color': color,
        'category_parents_id': categoryParentsId,
        'business_id': businessId,
        'is_active': isActive,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(), // Added
      };

  factory CategoryModel.fromDbLocal(Map<String, dynamic> map) {
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
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return CategoryModel(
      id: toInt(map['id']),
      idServer: toInt(map['id_server']), // Added
      name: map['name'] as String?,
      value: toDouble(map['value']),
      color: toInt(map['color']),
      categoryParentsId: toInt(map['category_parents_id']),
      businessId: toInt(map['business_id']),
      isActive: _toBool(map['is_active']),
      deletedAt: toDate(map['deleted_at']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      syncedAt: toDate(map['synced_at']), // Added
    );
  }
}
