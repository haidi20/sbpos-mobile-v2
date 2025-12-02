import 'package:product/domain/entities/cart_entity.dart';

class TransactionState {
  final String? error;
  final bool isLoading;
  final String orderNote;
  final int? activeNoteId;
  final String? searchQuery;
  final String activeCategory;
  final List<CartItemEntity> cart;

  TransactionState({
    this.error,
    this.searchQuery,
    this.activeNoteId,
    this.orderNote = "",
    this.isLoading = false,
    List<CartItemEntity>? cart,
    this.activeCategory = "All",
  }) : cart = cart ?? const [];

  TransactionState copyWith({
    String? error,
    bool? isLoading,
    String? orderNote,
    int? activeNoteId,
    String? searchQuery,
    String? activeCategory,
    List<CartItemEntity>? cart,
  }) {
    return TransactionState(
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
