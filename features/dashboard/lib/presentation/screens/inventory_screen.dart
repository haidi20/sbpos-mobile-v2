import 'package:core/core.dart';
import 'package:product/data/model/inventory_model.dart';

final List<InventoryItem> mockInventory = [
  InventoryItem(
      id: 1,
      name: "Kopi Susu Gula Aren",
      price: 18000,
      category: "Coffee",
      image: "https://picsum.photos/200/200?random=1",
      stock: 12,
      minStock: 20,
      unit: 'Cup'),
  InventoryItem(
      id: 2,
      name: "Cappuccino Panas",
      price: 22000,
      category: "Coffee",
      image: "https://picsum.photos/200/200?random=2",
      stock: 45,
      minStock: 15,
      unit: 'Cup'),
  InventoryItem(
      id: 3,
      name: "Nasi Goreng Spesial",
      price: 35000,
      category: "Food",
      image: "https://picsum.photos/200/200?random=3",
      stock: 8,
      minStock: 10,
      unit: 'Porsi'),
  InventoryItem(
      id: 4,
      name: "Mie Goreng Jawa",
      price: 32000,
      category: "Food",
      image: "https://picsum.photos/200/200?random=4",
      stock: 22,
      minStock: 10,
      unit: 'Porsi'),
  InventoryItem(
      id: 5,
      name: "Es Teh Manis",
      price: 8000,
      category: "Drink",
      image: "https://picsum.photos/200/200?random=5",
      stock: 100,
      minStock: 50,
      unit: 'Gelas'),
  InventoryItem(
      id: 6,
      name: "Biji Kopi Arabica",
      price: 0,
      category: "Ingredient",
      image: "https://picsum.photos/200/200?random=9",
      stock: 1,
      minStock: 3,
      unit: 'Kg'),
];

// --- 3. MAIN SCREEN ---

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // State
  final List<InventoryItem> _items = List.from(mockInventory);
  String _searchQuery = "";
  String _filter = 'all';

  // Colors (Matching the theme)
  final Color sbBlue = AppColors.sbBlue;
  final Color sbOrange = AppColors.sbOrange;
  final Color sbBg = AppColors.sbBg;

  // Logic: Adjust Stock
  void _handleStockAdjust(int id, int delta) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        int newStock = _items[index].stock + delta;
        _items[index].stock = newStock < 0 ? 0 : newStock;
      }
    });
  }

  // Logic: Computed Properties
  List<InventoryItem> get _filteredItems {
    return _items.where((item) {
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _filter == 'low' ? item.stock <= item.minStock : true;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _lowStockCount => _items.where((i) => i.stock <= i.minStock).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sbBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER SECTION (Sticky) ---
            Container(
              color: sbBg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          context.pop();
                        },
                        tooltip: 'Kembali',
                      ),
                      const Text(
                        'Manajemen Stok',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.history,
                              size: 20, color: Colors.grey),
                          onPressed: () {},
                          tooltip: 'Riwayat Stok',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Row (Filter Buttons)
                  Row(
                    children: [
                      // All Items Card
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = 'all'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _filter == 'all' ? sbBlue : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _filter == 'all'
                                    ? sbBlue
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Item',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _filter == 'all'
                                            ? Colors.blue.shade100
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_items.length}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _filter == 'all'
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons
                                      .inventory_2_outlined, // PackageCheck equivalent
                                  color: _filter == 'all'
                                      ? Colors.blue.shade200
                                      : Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Low Stock Card
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = 'low'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _filter == 'low'
                                  ? Colors.orange.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _filter == 'low'
                                    ? sbOrange
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stok Menipis',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_lowStockCount',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: sbOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons
                                      .warning_amber_rounded, // AlertCircle equivalent
                                  color: sbOrange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama barang...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.shade400),
                      suffixIcon:
                          Icon(Icons.filter_list, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: sbBlue.withOpacity(0.2), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- INVENTORY LIST ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: _filteredItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isLow = item.stock <= item.minStock;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Info
                        Row(
                          children: [
                            // Image with Overlay
                            Stack(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(item.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (isLow)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.error_outline,
                                            size: 20, color: Colors.red),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Text Details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isLow
                                            ? Colors.red.shade50
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${item.stock} ${item.unit}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isLow ? Colors.red : Colors.green,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Min: ${item.minStock}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right Buttons
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _StockBtn(
                                icon: Icons.remove,
                                onTap: () => _handleStockAdjust(item.id, -1),
                              ),
                              const SizedBox(width: 4),
                              _StockBtn(
                                icon: Icons.add,
                                onTap: () => _handleStockAdjust(item.id, 1),
                                isBlue: true,
                                color: sbBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Buttons
class _StockBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isBlue;
  final Color? color;

  const _StockBtn({
    required this.icon,
    required this.onTap,
    this.isBlue = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isBlue ? color : Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isBlue ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }
}
