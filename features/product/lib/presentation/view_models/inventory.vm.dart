import 'package:core/core.dart';
import 'package:product/data/dummies/inventory.dummy.dart';
import 'package:product/data/models/inventory.model.dart';
import 'package:product/presentation/view_models/inventory.state.dart';
import 'package:product/domain/usecases/get_product.usecase.dart';
import 'package:product/domain/usecases/update_product.usecase.dart';
import 'package:product/presentation/providers/product.provider.dart';

class InventoryViewModel extends StateNotifier<InventoryState> {
  final GetProduct _getProduct;
  final UpdateProduct _updateProduct;

  InventoryViewModel(this._getProduct, this._updateProduct)
      : super(const InventoryState()) {
    final items = List<InventoryItem>.from(inventoryList);
    state = state.copyWith(items: items);
  }

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void setFilter(String f) => state = state.copyWith(filter: f);

  Future<void> adjustStock(int id, int delta) async {
    final items = state.items.map((it) => it).toList();
    final idx = items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final oldStock = items[idx].stock;
    final newStock = (oldStock + delta).clamp(0, 999999).toInt();

    // Attempt to persist change to local DB via product usecase
    try {
      final res = await _getProduct.call(id, isOffline: true);
      res.fold((f) {
        // If get failed, fall back to local state update
        items[idx].stock = newStock;
        state = state.copyWith(items: items);
      }, (productEntity) async {
        final updated = productEntity.copyWith(qty: newStock.toDouble());
        final up = await _updateProduct.call(updated, isOffline: true);
        up.fold((f2) {
          // update failed: keep UI in sync but record error in state via loading? keep simple
          items[idx].stock = newStock;
          state = state.copyWith(items: items);
        }, (updatedEntity) {
          // success: sync UI with updatedEntity.qty
          items[idx].stock = (updatedEntity.qty ?? newStock.toDouble()).toInt();
          state = state.copyWith(items: items);
        });
      });
    } catch (e) {
      items[idx].stock = newStock;
      state = state.copyWith(items: items);
    }
  }

  List<InventoryItem> get filteredItems {
    final q = state.searchQuery.toLowerCase();
    return state.items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(q);
      final matchesFilter =
          state.filter == 'low' ? item.stock <= item.minStock : true;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get lowStockCount =>
      state.items.where((i) => i.stock <= i.minStock).length;
}

final inventoryViewModelProvider =
    StateNotifierProvider<InventoryViewModel, InventoryState>((ref) {
  final getProduct = ref.watch(productGetProductProvider);
  final updateProduct = ref.watch(productUpdateProductProvider);
  return InventoryViewModel(getProduct, updateProduct);
});
