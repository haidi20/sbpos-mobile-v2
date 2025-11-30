import 'package:product/data/model/product_model.dart';

final List<ProductModel> initialProducts = [
  ProductModel(
    id: 1,
    name: "Kopi Susu Gula Aren",
    price: 18000,
    category: "Coffee",
    image: "https://picsum.photos/200/200?random=1",
    status: 'active',
  ),
  ProductModel(
    id: 2,
    name: "Cappuccino Panas",
    price: 22000,
    category: "Coffee",
    image: "https://picsum.photos/200/200?random=2",
    status: 'active',
  ),
  ProductModel(
    id: 3,
    name: "Nasi Goreng Spesial",
    price: 35000,
    category: "Food",
    image: "https://picsum.photos/200/200?random=3",
    status: 'active',
  ),
  ProductModel(
    id: 6,
    name: "Croissant Butter",
    price: 25000,
    category: "Pastry",
    image: "https://picsum.photos/200/200?random=6",
    status: 'inactive',
  ),
];
