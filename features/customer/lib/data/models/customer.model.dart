class CustomerModel {
  final int? id;
  final int? idServer;
  final String? name;
  final String? phone;
  final String? note;
  final String? email;
  final DateTime? syncedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const CustomerModel({
    this.id,
    this.idServer,
    this.name,
    this.phone,
    this.note,
    this.email,
    this.syncedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  CustomerModel copyWith({
    int? id,
    int? idServer,
    String? name,
    String? phone,
    String? note,
    String? email,
    DateTime? syncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      email: email ?? this.email,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: _toInt(json['id']),
        idServer: _toInt(json['id']),
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        note: json['note'] as String?,
        email: json['email'] as String?,
        syncedAt: json['synced_at'] != null
            ? DateTime.tryParse(json['synced_at'])
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
        deletedAt: json['deleted_at'] != null
            ? DateTime.tryParse(json['deleted_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': idServer,
        'id_server': idServer,
        'name': name,
        'phone': phone,
        'note': note,
        'email': email,
        'synced_at': syncedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer,
        'name': name,
        'phone': phone,
        'note': note,
        'email': email,
        'synced_at': syncedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  factory CustomerModel.fromDbLocal(Map<String, dynamic> map) {
    return CustomerModel(
      id: _toInt(map['id']),
      idServer: _toInt(map['id_server']),
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      note: map['note'] as String?,
      email: map['email'] as String?,
      syncedAt: _toDate(map['synced_at']),
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
      deletedAt: _toDate(map['deleted_at']),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
