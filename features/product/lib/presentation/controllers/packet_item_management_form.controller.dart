import 'package:flutter/widgets.dart';
import 'package:product/domain/entities/packet_item.entity.dart';

/// Controller that owns transient editing controllers for the packet item form.
class PacketItemManagementFormController {
  PacketItemManagementFormController({PacketItemEntity? initial}) {
    value = initial ?? PacketItemEntity();
    nameController = TextEditingController();
    qtyController = TextEditingController(text: (value.qty ?? 1).toString());
    priceController =
        TextEditingController(text: (value.subtotal ?? 0).toString());
    discountController =
        TextEditingController(text: (value.discount ?? 0).toString());
  }

  late PacketItemEntity value;
  late TextEditingController nameController;
  late TextEditingController qtyController;
  late TextEditingController priceController;
  late TextEditingController discountController;

  /// Update internal `value` from text controllers. Caller should resolve
  /// `productId` based on `nameController.text` if needed.
  void updateFromControllers({int? productId}) {
    final qty = int.tryParse(qtyController.text) ?? 1;
    final price = int.tryParse(priceController.text) ?? 0;
    final discount = int.tryParse(discountController.text) ?? 0;
    final subtotal = (qty * price) - discount;
    value = value.copyWith(
        productId: productId ?? value.productId,
        qty: qty,
        subtotal: subtotal,
        discount: discount);
  }

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    priceController.dispose();
    discountController.dispose();
  }
}
