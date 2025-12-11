import 'package:customer/data/models/customer.model.dart';

class CustomerEntity {
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

  const CustomerEntity({
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

  CustomerEntity copyWith({
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
    return CustomerEntity(
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

  factory CustomerEntity.fromModel(CustomerModel model) {
    return CustomerEntity(
      id: model.id,
      idServer: model.idServer,
      name: model.name,
      phone: model.phone,
      note: model.note,
      email: model.email,
      syncedAt: model.syncedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
    );
  }

  CustomerModel toModel() {
    return CustomerModel(
      id: id,
      idServer: idServer,
      name: name,
      phone: phone,
      note: note,
      email: email,
      syncedAt: syncedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.name == name &&
        other.phone == phone &&
        other.note == note &&
        other.email == email &&
        other.syncedAt == syncedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        idServer,
        name,
        phone,
        note,
        email,
        syncedAt,
        createdAt,
        updatedAt,
        deletedAt,
      );

  @override
  String toString() {
    return '''CustomerEntity(
      id: $id,
      idServer: $idServer,
      name: $name,
      phone: $phone,
      note: $note,
      email: $email,
      syncedAt: $syncedAt,
      createdAt: $createdAt,
      updatedAt: $updatedAt,
      deletedAt: $deletedAt,
    )''';
  }

  // =======================================================
  // ⭐️ GETTER BARU: Mengambil Inisial Nama (getFirstName)
  // =======================================================
  String get getFirstName {
    // Ambil nilai properti name
    final customerName = name;

    // Periksa apakah customerName tidak null dan tidak kosong,
    // lalu ambil karakter pertama. Jika tidak, kembalikan string kosong.
    if (customerName != null && customerName.isNotEmpty) {
      return customerName.substring(0, 1);
    }

    return '';

    // Atau menggunakan sintaks yang lebih ringkas seperti yang Anda berikan:
    // return (customerName?.isNotEmpty == true) ? customerName!.substring(0, 1) : '';
  }
  // =======================================================
}
