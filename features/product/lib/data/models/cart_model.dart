import 'package:product/data/models/product_model.dart';
import 'package:product/data/models/category_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  String note;

  CartItem({required this.product, required this.quantity, this.note = ''});

  double get subtotal => (product.price ?? 0) * quantity;
}
