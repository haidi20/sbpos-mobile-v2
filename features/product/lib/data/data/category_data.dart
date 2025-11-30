import 'package:core/core.dart';
import 'package:product/data/models/category_model.dart';

// final List<CategoryModel> categories = ["All", "Coffee", "Food", "Drink", "Pastry"];
final List<CategoryModel> categories = [
  CategoryModel(
    id: 1,
    name: "All",
  ),
  CategoryModel(
    id: 2,
    name: "Coffee",
  ),
  CategoryModel(
    id: 3,
    name: "Food",
  ),
  CategoryModel(
    id: 4,
    name: "Drink",
  ),
  CategoryModel(
    id: 5,
    name: "Pastry",
  ),
];

final List<CategoryModel> categoryData = [
  CategoryModel(
    name: 'Coffee',
    value: 45,
    color: AppColors.sbBlue.value,
  ),
  CategoryModel(
    name: 'Food',
    value: 30,
    color: AppColors.sbOrange.value,
  ),
  CategoryModel(
    name: 'Drink',
    value: 15,
    color: AppColors.sbLightBlue.value,
  ),
  CategoryModel(
    name: 'Snack',
    value: 10,
    color: AppColors.sbGold.value,
  ),
];
