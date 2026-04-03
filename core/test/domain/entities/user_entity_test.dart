import 'package:flutter_test/flutter_test.dart';
import 'package:core/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    const tWarehouseId = 123;
    const tOutletId = 123;

    test('should support outletId field', () {
      const entity = UserEntity(
        id: 1,
        username: 'test',
        warehouseId: tWarehouseId,
        outletId: tOutletId,
      );

      expect(entity.warehouseId, tWarehouseId);
      expect(entity.outletId, tOutletId);
    });

    test('should be equal when fields match including outletId', () {
      const entity1 =
          UserEntity(id: 1, warehouseId: tWarehouseId, outletId: tOutletId);
      const entity2 =
          UserEntity(id: 1, warehouseId: tWarehouseId, outletId: tOutletId);

      expect(entity1, entity2);
    });
  });
}
