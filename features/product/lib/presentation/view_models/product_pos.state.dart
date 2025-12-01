import 'package:product/domain/entities/cart_entity.dart';

class ProductPosState {
  final String? error;
  final bool isLoading;
  final String orderNote;
  final int? activeNoteId;
  final String? searchQuery;
  final String activeCategory;
  final List<CartItemEntity> cart;

  ProductPosState({
    this.error,
    this.searchQuery,
    this.activeNoteId,
    this.orderNote = "",
    this.isLoading = false,
    List<CartItemEntity>? cart,
    this.activeCategory = "All",
  }) : cart = cart ?? const [];

  ProductPosState copyWith({
    String? error,
    bool? isLoading,
    String? orderNote,
    int? activeNoteId,
    String? searchQuery,
    String? activeCategory,
    List<CartItemEntity>? cart,
  }) {
    return ProductPosState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: activeCategory ?? this.activeCategory,
      cart: cart ?? this.cart,
      orderNote: orderNote ?? this.orderNote,
      activeNoteId: activeNoteId ?? this.activeNoteId,
    );
  }
}
