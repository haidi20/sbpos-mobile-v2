import 'package:product/data/models/product_model.dart';
import 'package:product/data/models/category_model.dart';

final List<ProductModel> initialProducts = [
  ProductModel(
    id: 1,
    name: "Kopi Susu Gula Aren",
    price: 18000.0,
    category: CategoryModel(name: 'Coffee'),
    image: "https://picsum.photos/200/200?random=1",
    isActive: true,
  ),
  ProductModel(
    id: 2,
    name: "Cappuccino Panas",
    price: 22000.0,
    category: CategoryModel(name: 'Coffee'),
    image: "https://picsum.photos/200/200?random=2",
    isActive: true,
  ),
  ProductModel(
    id: 3,
    name: "Nasi Goreng Spesial",
    price: 35000.0,
    category: CategoryModel(name: 'Food'),
    image: "https://picsum.photos/200/200?random=3",
    isActive: true,
  ),
  ProductModel(
    id: 6,
    name: "Croissant Butter",
    price: 25000.0,
    category: CategoryModel(name: 'Pastry'),
    image: "https://picsum.photos/200/200?random=6",
    isActive: false,
  ),
];
