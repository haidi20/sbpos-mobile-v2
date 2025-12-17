import 'package:core/core.dart';
import 'package:product/domain/entities/category.entity.dart';

const List<CategoryEntity> categories = [
  CategoryEntity(
    id: 1,
    name: "All",
  ),
  CategoryEntity(
    id: 2,
    name: "Coffee",
  ),
  CategoryEntity(
    id: 3,
    name: "Food",
  ),
  CategoryEntity(
    id: 4,
    name: "Drink",
  ),
  CategoryEntity(
    id: 5,
    name: "Pastry",
  ),
];

final List<CategoryEntity> categoryData = [
  CategoryEntity(
    name: 'Coffee',
    value: 45,
    color: AppColors.sbBlue.value,
  ),
  CategoryEntity(
    name: 'Food',
    value: 30,
    color: AppColors.sbOrange.value,
  ),
  CategoryEntity(
    name: 'Drink',
    value: 15,
    color: AppColors.sbLightBlue.value,
  ),
  CategoryEntity(
    name: 'Snack',
    value: 10,
    color: AppColors.sbGold.value,
  ),
];
