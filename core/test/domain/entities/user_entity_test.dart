import 'package:flutter_test/flutter_test.dart';
import 'package:core/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    const tRoleId = 1;
    const tOutletId = 123;

    test('should support roleId and outletId fields', () {
      const entity = UserEntity(
        id: 1,
        username: 'test',
        roleId: tRoleId,
        outletId: tOutletId,
      );

      expect(entity.roleId, tRoleId);
      expect(entity.outletId, tOutletId);
    });

    test('should be equal when fields match including roleId and outletId', () {
      const entity1 = UserEntity(
          id: 1,
          roleId: tRoleId,
          outletId: tOutletId);
      const entity2 = UserEntity(
          id: 1,
          roleId: tRoleId,
          outletId: tOutletId);

      expect(entity1, entity2);
    });
  });
}
