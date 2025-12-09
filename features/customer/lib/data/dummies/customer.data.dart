import 'package:customer/domain/entities/customer.entity.dart';

final List<CustomerEntity> initialCustomers = [
  CustomerEntity(
    id: 1,
    name: "Andi Wijaya",
    phone: "081234567890",
    note: "Suka extra shot",
    createdAt: DateTime.tryParse("2023-10-01T08:00:00"),
    updatedAt: DateTime.tryParse("2023-10-20T10:00:00"),
  ),
  CustomerEntity(
    id: 2,
    name: "Budi Santoso",
    phone: "081987654321",
    createdAt: DateTime.tryParse("2023-09-20T08:00:00"),
    updatedAt: DateTime.tryParse("2023-10-15T09:30:00"),
  ),
  CustomerEntity(
    id: 3,
    name: "Citra Lestari",
    phone: "081345678901",
    createdAt: DateTime.tryParse("2023-09-10T08:00:00"),
  ),
  CustomerEntity(
    id: 4,
    name: "Dewi Putri",
    phone: "081299887766",
    note: "Alergi susu sapi (Oatmilk only)",
    createdAt: DateTime.tryParse("2023-08-01T08:00:00"),
    updatedAt: DateTime.tryParse("2023-10-23T11:00:00"),
  ),
  CustomerEntity(
    id: 5,
    name: "Eko Prasetyo",
    phone: "085712345678",
    createdAt: DateTime.tryParse("2023-10-01T07:45:00"),
  ),
];
