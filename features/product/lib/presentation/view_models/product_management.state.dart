import 'package:product/domain/entities/product.entity.dart';

class ProductManagementState {
  final bool loading;
  final List<ProductEntity> products;
  final String? error;
  final bool isForm;
  final String? searchQuery;

  const ProductManagementState({
    this.loading = false,
    this.products = const [],
    this.error,
    this.isForm = false,
    this.searchQuery,
  });

  ProductManagementState copyWith({
    bool? loading,
    List<ProductEntity>? products,
    String? error,
    bool? isForm,
    String? searchQuery,
  }) {
    return ProductManagementState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      error: error ?? this.error,
      isForm: isForm ?? this.isForm,
      searchQuery: searchQuery ?? this.searchQuery,
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
