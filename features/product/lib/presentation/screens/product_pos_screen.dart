import 'package:core/core.dart'; // Sesuaikan import
import 'package:product/data/model/cart_model.dart';
import 'package:product/data/model/product_model.dart';
import 'package:product/presentation/component/product_card.dart';
import 'package:product/presentation/widgets/cart_bottom_sheet.dart';

class ProductPosScreen extends StatefulWidget {
  const ProductPosScreen({super.key});

  @override
  State<ProductPosScreen> createState() => _ProductPosScreenState();
}

class _ProductPosScreenState extends State<ProductPosScreen> {
  // State
  String _activeCategory = "All";
  final List<CartItem> _cart = [];
  String _orderNote = "";
  int? _activeNoteId;

  // Controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Logic: Add to Cart
  void _addToCart(ProductModel product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product, quantity: 1, note: ''));
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

  // Logic: Update Item Note
  void _updateItemNote(int productId, String note) {
    setState(() {
      final index = _cart.indexWhere((i) => i.product.id == productId);
      if (index != -1) {
        _cart[index].note = note;
      }
    });
  }

  // Logic: Clear Cart
  void _clearCart() {
    setState(() {
      _cart.clear();
      _orderNote = "";
      _activeNoteId = null;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Logic: Set Active Note ID
  void _setActiveNoteId(int? id) {
    setState(() {
      _activeNoteId = id;
    });
  }

  double get _cartTotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  int get _cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(
        cart: _cart,
        total: _cartTotal,
        onUpdateQty: _updateQuantity,
        onClear: _clearCart,
        orderNote: _orderNote,
        onOrderNoteChanged: (v) => setState(() => _orderNote = v),
        onUpdateItemNote: _updateItemNote,
        activeNoteId: _activeNoteId,
        onSetActiveId: _setActiveNoteId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = mockProducts.where((p) {
      final matchesCategory =
          _activeCategory == "All" || p.category == _activeCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          (p.name != null &&
              p.name!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: GestureDetector(
        // 👇 Ini kuncinya: DETEKSI TAP DI MANA SAJA & TUTUP KEYBOARD
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        // 👇 Pastikan tap tetap sampai ke widget di dalam (button, card, dll)
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // --- HEADER SECTION ---
                  Container(
                    color: AppColors.sbBg,
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            textInputAction: TextInputAction.search,
                            // ✅ Tetap pertahankan onTapOutside sebagai cadangan
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari produk...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.grey),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = "");
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.sbBlue.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Category List — ✅ onTap di sini sekarang otomatis unfocus TextField
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isActive = _activeCategory == cat;
                              return InkWell(
                                onTap: () {
                                  setState(() => _activeCategory = cat);
                                  // ✅ Tidak perlu lagi panggil unfocus di sini — GestureDetector global sudah handle
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.sbBlue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: isActive
                                        ? null
                                        : Border.all(
                                            color: Colors.grey.shade300),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- PRODUCT GRID ---
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(child: Text("Produk tidak ditemukan"))
                        : GridView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                sbBlue: AppColors.sbBlue,
                                sbOrange: AppColors.sbOrange,
                                onTap: () {
                                  // ✅ Tidak perlu unfocus di sini — GestureDetector global sudah handle
                                  _addToCart(product);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),

              // --- FLOATING CART BUTTON ---
              _cartBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartBottomButton() {
    if (_cart.isNotEmpty) {
      return Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _showCartSheet();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.sbBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sbBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- BAGIAN KIRI (TIDAK DIUBAH/DIKURANGI SESUAI REQUEST) ---
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined, // Icon Relevan
                          color: Colors.white,
                          size: 30,
                        ),
                        // Badge Total Item di Atas Kanan Icon
                        Positioned(
                          right: -5,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.sbOrange, // Warna Badge
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.sbBlue,
                                width: 1,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                "$_cartCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Rp ${_cartTotal.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // --- BAGIAN KANAN (DITAMBAHKAN ICON & BADGE) ---
                const Row(
                  children: [
                    // Teks Asli
                    Text(
                      "Keranjang",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
