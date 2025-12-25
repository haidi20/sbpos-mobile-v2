import 'package:flutter/widgets.dart';

/// Lightweight model used by the presentation layer for packet items.
class ProductItem {
  ProductItem({
    required this.id,
    this.name = '',
    this.qty = 1,
    this.price = 0,
    this.discount = 0,
  });

  final String id;
  String name;
  int qty;
  int price;
  int discount;

  int get subtotal => (qty * price) - discount;

  ProductItem copyWith({
    String? id,
    String? name,
    int? qty,
    int? price,
    int? discount,
  }) {
    return ProductItem(
      id: id ?? this.id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      discount: discount ?? this.discount,
    );
  }
}

/// Controller that owns transient editing controllers for the item form.
class PacketItemManagementFormController {
  PacketItemManagementFormController({ProductItem? initial}) {
    value = initial ??
        ProductItem(id: DateTime.now().millisecondsSinceEpoch.toString());
    nameController = TextEditingController(text: value.name);
    qtyController = TextEditingController(text: value.qty.toString());
    priceController = TextEditingController(text: value.price.toString());
    discountController = TextEditingController(text: value.discount.toString());
  }

  late ProductItem value;
  late TextEditingController nameController;
  late TextEditingController qtyController;
  late TextEditingController priceController;
  late TextEditingController discountController;

  void updateFromControllers() {
    value.name = nameController.text;
    value.qty = int.tryParse(qtyController.text) ?? 1;
    value.price = int.tryParse(priceController.text) ?? 0;
    value.discount = int.tryParse(discountController.text) ?? 0;
  }

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    priceController.dispose();
    discountController.dispose();
  }
}
