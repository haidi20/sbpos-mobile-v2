// Domain entity for warehouse

import 'package:warehouse/data/models/warehouse_model.dart';

class WarehouseEntity {
  final int? id;
  final int? idServer;
  final String? name;
  final String? logoUrl;
  final String? address;
  final double? distance;
  final int? businessId;
  final bool isActive;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  const WarehouseEntity({
    this.id,
    this.idServer,
    this.name,
    this.logoUrl,
    this.address,
    this.businessId,
    this.distance,
    this.isActive = false,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  WarehouseEntity copyWith({
    int? id,
    int? idServer,
    String? name,
    String? logoUrl,
    String? address,
    int? businessId,
    double? distance,
    bool? isActive,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return WarehouseEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
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

  factory WarehouseEntity.fromModel(WarehouseModel model) {
    return WarehouseEntity(
      id: model.id,
      idServer: model.idServer,
      name: model.name,
      logoUrl: model.logo,
      address: model.address,
      distance: model.distance,
      businessId: model.businessId,
      isActive: model.isActive ?? false,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncedAt: model.syncedAt,
    );
  }

  WarehouseModel toModel() {
    return WarehouseModel(
      id: id,
      idServer: idServer,
      name: name,
      logo: logoUrl,
      address: address,
      businessId: businessId,
      isActive: isActive,
      distance: distance,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WarehouseEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.name == name &&
        other.logoUrl == logoUrl &&
        other.address == address &&
        other.businessId == businessId &&
        other.distance == distance &&
        other.isActive == isActive &&
        other.deletedAt == deletedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        idServer,
        name,
        logoUrl,
        address,
        businessId,
        distance,
        isActive,
        deletedAt,
        createdAt,
        updatedAt,
      );
}
