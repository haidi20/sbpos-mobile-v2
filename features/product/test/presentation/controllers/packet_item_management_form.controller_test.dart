import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/presentation/controllers/packet_item_management_form.controller.dart';

void main() {
  group('PacketItemManagementFormController', () {
    test('harus menginisialisasi controller dengan nilai default', () {
      final controller = PacketItemManagementFormController();
      
      expect(controller.qtyController.text, '1');
      expect(controller.priceController.text, '0');
      expect(controller.discountController.text, '0');
    });

    test('harus memperbarui nilai dari text controller', () {
      final item = PacketItemEntity(productId: 1);
      final controller = PacketItemManagementFormController(initial: item);
      
      controller.qtyController.text = '2';
      controller.priceController.text = '10000';
      controller.discountController.text = '2000';
      
      controller.updateFromControllers();
      
      // Subtotal = (2 * 10000) - 2000 = 18000
      expect(controller.value.qty, 2);
      expect(controller.value.subtotal, 18000);
      expect(controller.value.discount, 2000);
    });
  });
}
