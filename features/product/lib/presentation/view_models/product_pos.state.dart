import 'package:product/data/models/cart_model.dart';

class ProductPosState {
  final String? error;
  final bool isLoading;
  final String orderNote;
  final int? activeNoteId;
  final List<CartItem> cart;
  final String? searchQuery;
  final String activeCategory;

  ProductPosState({
    this.error,
    this.searchQuery,
    this.activeNoteId,
    List<CartItem>? cart,
    this.isLoading = false,
    this.orderNote = "",
    this.activeCategory = "All",
  }) : cart = cart ?? const [];

  ProductPosState copyWith({
    String? error,
    bool? isLoading,
    String? searchQuery,
    String? activeCategory,
    List<CartItem>? cart,
    String? orderNote,
    int? activeNoteId,
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
