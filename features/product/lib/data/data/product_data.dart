import 'package:product/data/models/product_model.dart';
import 'package:product/data/models/category_model.dart';

final List<ProductModel> initialProducts = [
  ProductModel(
      id: 1,
      name: "Kopi Susu Gula Aren",
      price: 18000,
      category: CategoryModel(
        name: "Coffee",
      ),
      image: "https://picsum.photos/200/200?random=1"),
  ProductModel(
      id: 2,
      name: "Cappuccino Panas",
      price: 22000,
      category: CategoryModel(
        name: "Coffee",
      ),
      image: "https://picsum.photos/200/200?random=2"),
  ProductModel(
      id: 3,
      name: "Nasi Goreng Spesial",
      price: 35000,
      category: CategoryModel(
        name: "Food",
      ),
      image: "https://picsum.photos/200/200?random=3"),
  ProductModel(
      id: 4,
      name: "Mie Goreng Jawa",
      price: 32000,
      category: CategoryModel(
        name: "Food",
      ),
      image: "https://picsum.photos/200/200?random=4"),
  ProductModel(
      id: 5,
      name: "Es Teh Manis",
      price: 8000,
      category: CategoryModel(
        name: "Drink",
      ),
      image: "https://picsum.photos/200/200?random=5"),
  ProductModel(
      id: 6,
      name: "Croissant Butter",
      price: 25000,
      category: CategoryModel(
        name: "Pastry",
      ),
      image: "https://picsum.photos/200/200?random=6"),
  ProductModel(
      id: 7,
      name: "Americano Iced",
      price: 20000,
      category: CategoryModel(
        name: "Coffee",
      ),
      image: "https://picsum.photos/200/200?random=7"),
  ProductModel(
      id: 8,
      name: "Lemon Tea",
      price: 12000,
      category: CategoryModel(
        name: "Drink",
      ),
      image: "https://picsum.photos/200/200?random=8"),
];
