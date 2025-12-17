import 'package:product/domain/entities/product.entity.dart';

class ProductManagementState {
  final bool loading;
  final List<ProductEntity> products;
  final String? error;
  final bool isForm;
  final String? searchQuery;
  final String activeCategory;

  const ProductManagementState({
    this.loading = false,
    this.products = const [],
    this.error,
    this.isForm = false,
    this.searchQuery,
    this.activeCategory = 'All',
  });

  ProductManagementState copyWith({
    bool? loading,
    List<ProductEntity>? products,
    String? error,
    bool? isForm,
    String? searchQuery,
    String? activeCategory,
  }) {
    return ProductManagementState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      error: error ?? this.error,
      isForm: isForm ?? this.isForm,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }

  factory ProductManagementState.cleared() {
    return const ProductManagementState(
      loading: false,
      products: [],
      error: null,
      isForm: false,
      searchQuery: null,
    );
  }
}
