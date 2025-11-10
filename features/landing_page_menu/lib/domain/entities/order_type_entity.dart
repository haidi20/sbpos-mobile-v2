import 'package:landing_page_menu/data/models/order_type_model.dart';

class OrderTypeEntity {
  final int? id;
  final int? idServer;
  final String name;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  const OrderTypeEntity({
    this.id,
    this.idServer,
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
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return OrderTypeEntity(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  factory OrderTypeEntity.fromModel(OrderTypeModel model) {
    return OrderTypeEntity(
      id: model.id,
      idServer:
          model.id, // atau model.idServer jika model menyediakan field terpisah
      name: model.name,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncedAt: model.updatedAt, // atau null, tergantung strategi sinkronisasi
    );
  }

  OrderTypeModel toModel() {
    return OrderTypeModel(
      id: id,
      name: name,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Jika kamu tetap ingin `props` untuk keperluan custom equality (opsional)
  List<Object?> get props => [
        id,
        idServer,
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
      name,
      deletedAt?.millisecondsSinceEpoch,
      createdAt?.millisecondsSinceEpoch,
      updatedAt?.millisecondsSinceEpoch,
      syncedAt?.millisecondsSinceEpoch,
    ]);
  }
}
