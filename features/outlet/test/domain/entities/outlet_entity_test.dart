import 'package:flutter_test/flutter_test.dart';
import 'package:outlet/data/models/outlet.model.dart';
import 'package:outlet/domain/entities/outlet.entity.dart';

void main() {
  final tModel = OutletModel(
    id: 1,
    idServer: 9,
    name: 'Outlet Pettarani',
    logo: 'https://example.com/logo.png',
    address: 'Jl. Pettarani',
    businessId: 1,
    isActive: true,
    distance: 1.5,
  );

  final tEntity = OutletEntity(
    id: 1,
    idServer: 9,
    name: 'Outlet Pettarani',
    logoUrl: 'https://example.com/logo.png',
    address: 'Jl. Pettarani',
    businessId: 1,
    isActive: true,
    distance: 1.5,
  );

  group('OutletEntity', () {
    test('fromModel mapping should be correct', () {
      final result = OutletEntity.fromModel(tModel);
      expect(result, tEntity);
    });

    test('toModel mapping should be correct', () {
      final result = tEntity.toModel();
      expect(result, tModel);
    });

    test('copyWith should copy with new values', () {
      final updated = tEntity.copyWith(name: 'Updated Name');
      expect(updated.name, 'Updated Name');
      expect(updated.id, tEntity.id);
    });
  });
}
