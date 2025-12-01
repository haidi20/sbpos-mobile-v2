import 'package:core/core.dart';
import 'product_pos.state.dart';
import 'package:product/domain/entities/cart_entity.dart';
import 'package:product/domain/entities/product_entity.dart';

class ProductPosViewModel extends StateNotifier<ProductPosState> {
  ProductPosViewModel() : super(ProductPosState());

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get cartTotal =>
      formatRupiah(state.cart.fold(0, (sum, item) => sum + item.subtotal));

  int get cartCount => state.cart.fold(0, (sum, item) => sum + item.quantity);

  TextEditingController get searchController => _searchController;

  void setUpdateQuantity(int productId, int delta) {
    final index = state.cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      final updatedCart = List<CartItemEntity>.from(state.cart);
      final newQuantity = updatedCart[index].quantity + delta;
      if (newQuantity <= 0) {
        updatedCart.removeAt(index);
      } else {
        final old = updatedCart[index];
        updatedCart[index] = CartItemEntity(
          product: old.product,
          quantity: newQuantity,
          note: old.note,
        );
      }
      state = state.copyWith(cart: updatedCart);
    }
  }

  // Update Item Note
  void setItemNote(int productId, String note) {
    final index = state.cart.indexWhere((i) => i.product.id == productId);
    if (index != -1) {
      final updatedCart = List<CartItemEntity>.from(state.cart);
      final old = updatedCart[index];
      updatedCart[index] = CartItemEntity(
        product: old.product,
        quantity: old.quantity,
        note: note,
      );
      state = state.copyWith(cart: updatedCart);
    }
  }

  // Set Order Note
  void setOrderNote(String note) {
    state = state.copyWith(orderNote: note);
  }

  // Set active category
  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Clear Cart
  void clearCart() {
    state = state.copyWith(
      cart: [],
      orderNote: "",
      activeNoteId: null,
    );
  }

  // Set Active Note ID
  void setActiveNoteId(int? id) {
    state = state.copyWith(activeNoteId: id);
  }

  // Add to Cart
  void onAddToCart(ProductEntity product) {
    final index =
        state.cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      final updatedCart = List<CartItemEntity>.from(state.cart);
      final old = updatedCart[index];
      updatedCart[index] = CartItemEntity(
        product: old.product,
        quantity: old.quantity + 1,
        note: old.note,
      );
      state = state.copyWith(cart: updatedCart);
    } else {
      final updatedCart = List<CartItemEntity>.from(state.cart)
        ..add(CartItemEntity(
          note: '',
          quantity: 1,
          product: product,
        ));
      state = state.copyWith(cart: updatedCart);
    }
  }
}
