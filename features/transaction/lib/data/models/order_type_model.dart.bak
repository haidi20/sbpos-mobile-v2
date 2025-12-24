import 'package:transaction/domain/entitties/order_type.entity.dart';

class OrderTypeModel {
  final int? id;
  final String name;
  final int? idServer; // <-- ditambahkan
  final String? icon; // <-- ditambahkan

  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt; // <-- ditambahkan

  OrderTypeModel({
    this.id,
    this.idServer,
    required this.name,
    this.icon,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  OrderTypeModel copyWith({
    int? id,
    int? idServer,
    String? name,
    String? icon,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return OrderTypeModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory OrderTypeModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // parseString removed (unused) to satisfy analyzer

    return OrderTypeModel(
      id: parseInt(json['id']),
      idServer: parseInt(json['id']) ??
          parseInt(json[
              'id_server']), // bisa sesuaikan jika API punya field terpisah
      name: json['name'] as String? ?? '',
      deletedAt: parseDate(json['deleted_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      syncedAt: parseDate(json['synced_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_server': idServer,
      'name': name,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  // Konversi ke Entity
  OrderTypeEntity toEntity() {
    return OrderTypeEntity(
      id: id,
      idServer: idServer,
      name: name,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
    );
  }

  factory OrderTypeModel.fromEntity(OrderTypeEntity entity) {
    return OrderTypeModel(
      id: entity.id,
      idServer: entity.idServer,
      name: entity.name,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncedAt: entity.syncedAt,
    );
  }

  // Untuk database lokal (Sqflite)
  factory OrderTypeModel.fromDbLocal(Map<String, dynamic> map) {
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

    String? toStringVal(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      return v.toString();
    }

    return OrderTypeModel(
      id: toInt(map['id']),
      idServer: toInt(map['id_server']),
      name: map['name'] as String? ?? '',
      icon: toStringVal(map['icon']) ?? toStringVal(map['icon_url']),
      deletedAt: toDate(map['deleted_at']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      syncedAt: toDate(map['synced_at']),
    );
  }

  Map<String, dynamic> toDbLocal() {
    return {
      'id': id,
      'id_server': idServer,
      'name': name,
      'icon': icon,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }
}
