import 'package:core/core.dart';
import 'package:product/data/model/product_model.dart';
import 'package:product/presentation/widgets/cart_bottom_sheet.dart';

// --- 1. MODELS ---

// --- 2. MOCK DATA ---

final List<Product> mockProducts = [
  Product(
      id: 1,
      name: "Kopi Susu Gula Aren",
      price: 18000,
      category: "Coffee",
      image: "https://picsum.photos/200/200?random=1"),
  Product(
      id: 2,
      name: "Cappuccino Panas",
      price: 22000,
      category: "Coffee",
      image: "https://picsum.photos/200/200?random=2"),
  Product(
      id: 3,
      name: "Nasi Goreng Spesial",
      price: 35000,
      category: "Food",
      image: "https://picsum.photos/200/200?random=3"),
  Product(
      id: 4,
      name: "Mie Goreng Jawa",
      price: 32000,
      category: "Food",
      image: "https://picsum.photos/200/200?random=4"),
  Product(
      id: 5,
      name: "Es Teh Manis",
      price: 8000,
      category: "Drink",
      image: "https://picsum.photos/200/200?random=5"),
  Product(
      id: 6,
      name: "Croissant Butter",
      price: 25000,
      category: "Pastry",
      image: "https://picsum.photos/200/200?random=6"),
  Product(
      id: 7,
      name: "Americano Iced",
      price: 20000,
      category: "Coffee",
      image: "https://picsum.photos/200/200?random=7"),
  Product(
      id: 8,
      name: "Lemon Tea",
      price: 12000,
      category: "Drink",
      image: "https://picsum.photos/200/200?random=8"),
];

final List<String> categories = ["All", "Coffee", "Food", "Drink", "Pastry"];

// --- 4. MAIN SCREEN ---

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final Logger _logger = Logger('ProductScreen');

  String _activeCategory = "All";
  String _searchQuery = "";
  final List<CartItem> _cart = [];

  // Colors
  final Color sbBlue = const Color(0xFF1E40AF);
  final Color sbOrange = const Color(0xFFF97316);
  final Color sbBg = const Color(0xFFF8FAFC);

  // Logic: Add to Cart
  void _addToCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  // Logic: Update Quantity
  void _updateQuantity(int productId, int delta) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == productId);
      if (index != -1) {
        _cart[index].quantity += delta;
        if (_cart[index].quantity <= 0) {
          _cart.removeAt(index);
        }
      }
    });
  }

  // Logic: Calculate Totals
  double get _cartTotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  int get _cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  // Logic: Show Bottom Sheet
  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa full height
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(
        cart: _cart,
        total: _cartTotal,
        onUpdateQty: _updateQuantity,
        onClear: () => setState(() => _cart.clear()),
        sbBlue: sbBlue,
        sbOrange: sbOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter Products
    final filteredProducts = mockProducts.filter((p) {
      final matchesCategory =
          _activeCategory == "All" || p.category == _activeCategory;
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: sbBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // --- BACK BUTTON ---
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        _logger.info("Back to Dashboard");
                        context.pop();
                      },
                      tooltip: 'Kembali',
                    ),
                  ),
                ),
                // --- HEADER SECTION (Fixed) ---
                Container(
                  color: sbBg,
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Cari produk...',
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
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
                      ),

                      const SizedBox(height: 12),

                      // Category List (Horizontal Scroll)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: categories.map((cat) {
                            final isActive = _activeCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _activeCategory = cat),
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive ? sbBlue : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isActive
                                          ? sbBlue
                                          : Colors.grey.shade200,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                                color: Colors.blue
                                                    .withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- PRODUCT GRID (Scrollable) ---
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 100), // Bottom padding for floating button
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // Adjust card height
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductCard(
                        product: product,
                        sbBlue: sbBlue,
                        sbOrange: sbOrange,
                        onTap: () => _addToCart(product),
                      );
                    },
                  ),
                ),
              ],
            ),

            // --- FLOATING CART BUTTON ---
            if (_cart.isNotEmpty)
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _showCartSheet,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: sbBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: sbBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_cartCount Item',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Total',
                                    style: TextStyle(
                                        color: Colors.blue.shade100,
                                        fontSize: 10)),
                                Text(
                                  formatRupiah(_cartTotal),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text('Lihat Keranjang',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- 5. WIDGETS ---

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color sbBlue;
  final Color sbOrange;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.sbBlue,
    required this.sbOrange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(product.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 16, color: sbBlue),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah(product.price),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: sbOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ListFilter<T> on List<T> {
  List<T> filter(bool Function(T) test) {
    final List<T> result = [];
    for (var element in this) {
      if (test(element)) {
        result.add(element);
      }
    }
    return result;
  }
}
