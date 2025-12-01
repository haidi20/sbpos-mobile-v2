import 'package:product/domain/entities/product_entity.dart';

class CartItemEntity {
  String note;
  int quantity;
  final ProductEntity product;

  CartItemEntity({
    this.note = '',
    required this.product,
    required this.quantity,
  });

  double get subtotal => (product.price ?? 0) * quantity;
}
