
import '../../domain/entities/outlet_entity.dart';

class OutletModel {
  final int? id;
  final int? idServer;
  final String? name;
  final String? logo;
  final String? address;
  final double? distance;
  final int? businessId;
  final bool? isActive;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  OutletModel({
    this.id,
    this.idServer,
    this.name,
    this.logo,
    this.address,
    this.distance,
    this.businessId,
    this.isActive,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  OutletModel copyWith({
    int? id,
    int? idServer,
    String? name,
    String? logo,
    String? address,
    int? businessId,
    double? distance,
    bool? isActive,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return OutletModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      businessId: businessId ?? this.businessId,
      isActive: isActive ?? this.isActive,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory OutletModel.fromJson(Map<String, dynamic> json) => OutletModel(
        idServer: json['id'],
        name: json['name'],
        logo: json['logo'],
        address: json['address'],
        distance: json['distance'],
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
        syncedAt: json['synced_at'] != null
            ? DateTime.parse(json['synced_at'])
            : null,
      );

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
        'id_server': idServer,
        'name': name,
        'logo': logo,
        'address': address,
        'distance': distance,
        'business_id': businessId,
        'is_active': isActive,
        'deleted_at': deletedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory OutletModel.fromEntity(OutletEntity entity) {
    return OutletModel(
      id: entity.id,
      name: entity.name,
      logo: entity.logoUrl,
      address: entity.address,
      businessId: entity.businessId,
      isActive: entity.isActive,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncedAt: entity.syncedAt,
    );
  }

  OutletEntity toEntity() => OutletEntity(
        id: id,
        name: name,
        logoUrl: logo,
        address: address,
        businessId: businessId,
        isActive: isActive ?? false,
        deletedAt: deletedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncedAt: syncedAt,
      );

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer,
        'name': name,
        'address': address,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
      };

  factory OutletModel.fromDbLocal(Map<String, dynamic> map) {
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

    return OutletModel(
      id: toInt(map['id']),
      idServer: toInt(map['id_server']),
      name: map['name'] as String?,
      address: map['address'] as String?,
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      syncedAt: toDate(map['synced_at']),
    );
  }
}
