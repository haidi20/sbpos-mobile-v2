class InventoryItem {
  final int id;
  final String name;
  final double price;
  final String category;
  final String image;
  int stock;
  final int minStock;
  final String unit;

  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.stock,
    required this.minStock,
    required this.unit,
  });
}
