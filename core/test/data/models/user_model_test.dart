import 'package:flutter_test/flutter_test.dart';
import 'package:core/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    const tRoleId = 1;
    const tOutletId = 123;

    final tUserJson = {
      'id': 1,
      'username': 'testuser',
      'email': 'test@example.com',
      'role_id': tRoleId,
      'warehouse_id': tOutletId,
      'is_active': 1,
    };

    final tLoginResponseJson = {
      'id': 1,
      'name': 'testuser',
      'email': 'test@example.com',
      'role_id': tRoleId,
      'warehouse_id': tOutletId,
      'is_active': 1,
      'access_token': 'test_token',
      'refresh_token': 'test_refresh_token',
    };

    test('should return a valid model from JSON with role_id and outlet_id mapped from warehouse_id', () {
      // Act
      final result = UserModel.fromJson(tUserJson);

      // Assert
      expect(result.roleId, tRoleId);
      expect(result.outletId, tOutletId); 
    });

    test('should return a valid model from login response with role_id and outlet_id mapped', () {
      // Act
      final result = UserModel.fromLoginResponse(tLoginResponseJson);

      // Assert
      expect(result.roleId, tRoleId);
      expect(result.outletId, tOutletId);
    });

    test('should return a JSON map containing role_id and outlet_id (as warehouse_id)', () {
      // Arrange
      final model = UserModel(
        id: 1,
        username: 'test',
        roleId: tRoleId,
        outletId: tOutletId,
      );

      // Act
      final result = model.toJson();

      // Assert
      expect(result['role_id'], tRoleId);
      expect(result['warehouse_id'], tOutletId);
    });
  });
}
