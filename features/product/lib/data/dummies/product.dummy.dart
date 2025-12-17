import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/category.entity.dart';

const List<ProductEntity> initialProducts = [
  ProductEntity(
    id: 1,
    name: "Kopi Susu Gula Aren",
    price: 18000,
    category: CategoryEntity(
      name: "Coffee",
    ),
    image: "https://picsum.photos/200/200?random=1",
  ),
  ProductEntity(
    id: 2,
    name: "Cappuccino Panas",
    price: 22000,
    category: CategoryEntity(
      name: "Coffee",
    ),
    image: "https://picsum.photos/200/200?random=2",
  ),
  ProductEntity(
    id: 3,
    name: "Nasi Goreng Spesial",
    price: 35000,
    category: CategoryEntity(
      name: "Food",
    ),
    image: "https://picsum.photos/200/200?random=3",
  ),
  ProductEntity(
    id: 4,
    name: "Mie Goreng Jawa",
    price: 32000,
    category: CategoryEntity(
      name: "Food",
    ),
    image: "https://picsum.photos/200/200?random=4",
  ),
  ProductEntity(
    id: 5,
    name: "Es Teh Manis",
    price: 8000,
    category: CategoryEntity(
      name: "Drink",
    ),
    image: "https://picsum.photos/200/200?random=5",
  ),
  ProductEntity(
    id: 6,
    name: "Croissant Butter",
    price: 25000,
    category: CategoryEntity(
      name: "Pastry",
    ),
    image: "https://picsum.photos/200/200?random=6",
  ),
  ProductEntity(
    id: 7,
    name: "Americano Iced",
    price: 20000,
    category: CategoryEntity(
      name: "Coffee",
    ),
    image: "https://picsum.photos/200/200?random=7",
  ),
  ProductEntity(
    id: 8,
    name: "Lemon Tea",
    price: 12000,
    category: CategoryEntity(
      name: "Drink",
    ),
    image: "https://picsum.photos/200/200?random=8",
  ),
  ProductEntity(
    id: 9,
    name: "Teh Panas",
    price: 8000,
    category: CategoryEntity(
      name: "Drink",
    ),
    image: "https://picsum.photos/200/200?random=9",
  ),
  ProductEntity(
    id: 10,
    name: "Jus Jeruk",
    price: 12000,
    category: CategoryEntity(
      name: "Drink",
    ),
    image: "https://picsum.photos/200/200?random=10",
  ),
  ProductEntity(
    id: 11,
    name: "Ayam Goreng",
    price: 28000,
    category: CategoryEntity(
      name: "Food",
    ),
    image: "https://picsum.photos/200/200?random=11",
  ),
  ProductEntity(
    id: 12,
    name: "Ayam Bakar",
    price: 30000,
    category: CategoryEntity(
      name: "Food",
    ),
    image: "https://picsum.photos/200/200?random=12",
  ),
  ProductEntity(
    id: 13,
    name: "Bebek Goreng",
    price: 35000,
    category: CategoryEntity(
      name: "Food",
    ),
    image: "https://picsum.photos/200/200?random=13",
  ),
  ProductEntity(
    id: 14,
    name: "Bebek Bakar",
    price: 37000,
    category: CategoryEntity(
      name: "Food",
    ),
    image: "https://picsum.photos/200/200?random=14",
  ),
];
