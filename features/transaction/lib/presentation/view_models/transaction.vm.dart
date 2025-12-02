import 'package:core/core.dart';
import 'transaction.state.dart';
import 'package:product/domain/entities/product_entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class TransactionViewModel extends StateNotifier<TransactionState> {
  TransactionViewModel() : super(TransactionState()) {
    //
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionDetailEntity> get filteredDetails {
    final query = state.searchQuery?.toLowerCase() ?? "";
    final category = state.activeCategory;

    return state.details.where((item) {
      final matchesQuery =
          item.productName?.toLowerCase().contains(query) ?? false;
      final matchesCategory = category == "All" ||
          (item.note?.toLowerCase() == category.toLowerCase());
      return matchesQuery && matchesCategory;
    }).toList();
  }

  String get cartTotal {
    final total = state.details.fold<int>(0, (sum, item) {
      if (item.subtotal != null) return sum + (item.subtotal ?? 0);
      final price = item.productPrice ?? 0;
      final qty = item.qty ?? 0;
      return sum + (price * qty);
    });
    return formatRupiah(total.toDouble());
  }

  int get cartCount =>
      state.details.fold(0, (sum, item) => sum + (item.qty ?? 0));

  TextEditingController get searchController => _searchController;

  void setUpdateQuantity(int productId, int delta) {
    final index =
        state.details.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      final updated = List<TransactionDetailEntity>.from(state.details);
      final old = updated[index];
      final newQty = (old.qty ?? 0) + delta;
      if (newQty <= 0) {
        updated.removeAt(index);
      } else {
        final price = old.productPrice ?? 0;
        updated[index] = old.copyWith(
          qty: newQty,
          subtotal: price * newQty,
        );
      }
      state = state.copyWith(details: updated);
    }
  }

  // Update Item Note
  void setItemNote(int productId, String note) {
    final index = state.details.indexWhere((i) => i.productId == productId);
    if (index != -1) {
      final updated = List<TransactionDetailEntity>.from(state.details);
      final old = updated[index];
      updated[index] = old.copyWith(note: note);
      state = state.copyWith(details: updated);
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
      details: [],
      transaction: null,
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
    final index = state.details.indexWhere((d) => d.productId == product.id);
    if (index != -1) {
      final updated = List<TransactionDetailEntity>.from(state.details);
      final old = updated[index];
      final newQty = (old.qty ?? 0) + 1;
      updated[index] = old.copyWith(
        qty: newQty,
        subtotal: (old.productPrice ?? product.price?.toInt() ?? 0) * newQty,
      );
      state = state.copyWith(details: updated);
    } else {
      final newDetail = TransactionDetailEntity(
        productId: product.id,
        productName: product.name,
        productPrice: product.price?.toInt(),
        qty: 1,
        subtotal: product.price?.toInt(),
      );
      final updated = List<TransactionDetailEntity>.from(state.details)
        ..add(newDetail);
      state = state.copyWith(details: updated);
    }
  }
}
