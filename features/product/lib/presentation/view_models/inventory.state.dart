import 'package:product/data/models/inventory.model.dart';

class InventoryState {
  final bool loading;
  final List<InventoryItem> items;
  final String searchQuery;
  final String filter;

  const InventoryState({
    this.loading = false,
    this.items = const [],
    this.searchQuery = '',
    this.filter = 'all',
  });

  InventoryState copyWith({
    bool? loading,
    List<InventoryItem>? items,
    String? searchQuery,
    String? filter,
  }) {
    return InventoryState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }
}
