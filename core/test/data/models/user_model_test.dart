import 'package:flutter_test/flutter_test.dart';
import 'package:core/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    const tWarehouseId = 123;
    const tOutletId = 123;

    final tUserJson = {
      'id': 1,
      'username': 'testuser',
      'email': 'test@example.com',
      'role_id': 1,
      'warehouse_id': tWarehouseId,
      'is_active': 1,
    };

    final tLoginResponseJson = {
      'id': 1,
      'name': 'testuser',
      'email': 'test@example.com',
      'role_id': 1,
      'warehouse_id': tWarehouseId,
      'is_active': 1,
      'access_token': 'test_token',
      'refresh_token': 'test_refresh_token',
    };

    test('should return a valid model from JSON with outlet_id mirrored from warehouse_id', () {
      // Act
      final result = UserModel.fromJson(tUserJson);

      // Assert
      expect(result.warehouseId, tWarehouseId);
      expect(result.outletId, tOutletId); 
    });

    test('should return a valid model from login response with outlet_id mirrored', () {
      // Act
      final result = UserModel.fromLoginResponse(tLoginResponseJson);

      // Assert
      expect(result.warehouseId, tWarehouseId);
      expect(result.outletId, tOutletId);
    });

    test('should return a JSON map containing outlet_id', () {
      // Arrange
      // This part will fail to compile initially once we add outletId to the constructor
      final model = UserModel(
        id: 1,
        username: 'test',
        warehouseId: tWarehouseId,
        outletId: tOutletId,
      );

      // Act
      final result = model.toJson();

      // Assert
      expect(result['warehouse_id'], tWarehouseId);
      expect(result['outlet_id'], tOutletId);
    });
  });
}
