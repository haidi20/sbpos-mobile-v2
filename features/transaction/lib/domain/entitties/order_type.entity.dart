import 'package:transaction/data/models/order_type_model.dart';

class OrderTypeEntity {
  final int? id;
  final int? idServer;
  final String name;
  final String? icon;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  const OrderTypeEntity({
    this.id,
    this.idServer,
    this.icon,
    required this.name,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  OrderTypeEntity copyWith({
    int? id,
    int? idServer,
    String? name,
    String? icon,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return OrderTypeEntity(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      idServer: idServer ?? this.idServer,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory OrderTypeEntity.fromModel(OrderTypeModel model) {
    return OrderTypeEntity(
      id: model.id,
      idServer: model.id,
      icon: model.icon,
      name: model.name,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncedAt: model.updatedAt,
    );
  }

  OrderTypeModel toModel() {
    return OrderTypeModel(
      id: id,
      name: name,
      icon: icon,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Jika kamu tetap ingin `props` untuk keperluan custom equality (opsional)
  List<Object?> get props => [
        id,
        idServer,
        icon,
        name,
        deletedAt?.millisecondsSinceEpoch,
        createdAt?.millisecondsSinceEpoch,
        updatedAt?.millisecondsSinceEpoch,
        syncedAt?.millisecondsSinceEpoch,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderTypeEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.icon == icon &&
        other.name == name &&
        other.deletedAt?.millisecondsSinceEpoch ==
            deletedAt?.millisecondsSinceEpoch &&
        other.createdAt?.millisecondsSinceEpoch ==
            createdAt?.millisecondsSinceEpoch &&
        other.updatedAt?.millisecondsSinceEpoch ==
            updatedAt?.millisecondsSinceEpoch &&
        other.syncedAt?.millisecondsSinceEpoch ==
            syncedAt?.millisecondsSinceEpoch;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      idServer,
      icon,
      name,
      deletedAt?.millisecondsSinceEpoch,
      createdAt?.millisecondsSinceEpoch,
      updatedAt?.millisecondsSinceEpoch,
      syncedAt?.millisecondsSinceEpoch,
    ]);
  }
}
