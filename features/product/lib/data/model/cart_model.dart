import 'package:product/data/model/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  String note;

  CartItem({required this.product, required this.quantity, this.note = ''});

  double get subtotal => (product.price ?? 0) * quantity;
}

final List<ProductModel> mockProducts = [
  ProductModel(
      id: 1,
      name: "Kopi Susu Gula Aren",
      price: 18000,
      category: "Coffee",
      image: "https://picsum.photos/200/200?random=1"),
  ProductModel(
      id: 2,
      name: "Cappuccino Panas",
      price: 22000,
      category: "Coffee",
      image: "https://picsum.photos/200/200?random=2"),
  ProductModel(
      id: 3,
      name: "Nasi Goreng Spesial",
      price: 35000,
      category: "Food",
      image: "https://picsum.photos/200/200?random=3"),
  ProductModel(
      id: 4,
      name: "Mie Goreng Jawa",
      price: 32000,
      category: "Food",
      image: "https://picsum.photos/200/200?random=4"),
  ProductModel(
      id: 5,
      name: "Es Teh Manis",
      price: 8000,
      category: "Drink",
      image: "https://picsum.photos/200/200?random=5"),
  ProductModel(
      id: 6,
      name: "Croissant Butter",
      price: 25000,
      category: "Pastry",
      image: "https://picsum.photos/200/200?random=6"),
  ProductModel(
      id: 7,
      name: "Americano Iced",
      price: 20000,
      category: "Coffee",
      image: "https://picsum.photos/200/200?random=7"),
  ProductModel(
      id: 8,
      name: "Lemon Tea",
      price: 12000,
      category: "Drink",
      image: "https://picsum.photos/200/200?random=8"),
];

final List<String> categories = ["All", "Coffee", "Food", "Drink", "Pastry"];
