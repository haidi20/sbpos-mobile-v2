import 'package:dashboard/presentation/widgets/bottom_nav_custom.dart';
import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});
}

class CartItem {
  final int id;
  final String name;
  final double price;
  int quantity;
  String note;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.note = '',
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), // bg-[#f3f4f6]
        primarySwatch: Colors.blue,
      ),
      home: const MainAppScreen(),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  // State: activeTab
  TabItem _activeTab = TabItem.dashboard;

  // State: cart
  final List<CartItem> _cart = [];

  // --- LOGIC: Handle Add To Cart ---
  // Replicates: const existingIndex = prev.findIndex(item => item.id === product.id && (item.note || '') === note);
  void _handleAddToCart(Product product, int quantity, String note) {
    setState(() {
      // Cek index item yang punya ID sama DAN Note sama
      final existingIndex = _cart.indexWhere(
        (item) => item.id == product.id && (item.note.trim() == note.trim()),
      );

      if (existingIndex >= 0) {
        // Jika ada, update quantity
        _cart[existingIndex].quantity += quantity;
      } else {
        // Jika tidak ada, tambah item baru
        _cart.add(CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          quantity: quantity,
          note: note,
        ));
      }
    });

    // Feedback visual (Snackbar)
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
    );
  }

  // --- LOGIC: Handle FAB Click ---
  void _handleFabClick() {
    setState(() {
      _activeTab = TabItem.order;
    });
  }

  // --- LOGIC: Switch Tab ---
  void _onTabSelected(int index) {
    setState(() {
      _activeTab = index == 0 ? TabItem.dashboard : TabItem.order;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan index untuk BottomNavigationBar
    final int currentIndex = _activeTab == TabItem.dashboard ? 0 : 1;

    return Scaffold(
      // App Bar (Optional, agar terlihat rapi)
      appBar: AppBar(
        title: Text(_activeTab == TabItem.dashboard ? "Dashboard" : "Order"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),

      // Main Content Area
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _activeTab == TabItem.dashboard
            ? const DashboardView() // Komponen Dashboard
            : OrderView(
                // Komponen Order + passing function
                cart: _cart,
                onAddToCart: _handleAddToCart,
              ),
      ),

      // Floating Action Button (Tombol Tengah)
      floatingActionButton: FloatingActionButton(
        onPressed: _handleFabClick,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation
      bottomNavigationBar: BottomNavCustom(
        activeTab: _activeTab,
        onTabChange: (tab) {
          setState(() {
            _activeTab = tab;
          });
        },
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Public screen used by router/tests
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MainAppScreen();
}

// --- MOCK COMPONENTS (Untuk menggantikan DashboardView & OrderView) ---

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Halaman Dashboard",
          style: TextStyle(fontSize: 20, color: Colors.grey)),
    );
  }
}

class OrderView extends StatelessWidget {
  final List<CartItem> cart;
  final Function(Product, int, String) onAddToCart;

  const OrderView({
    super.key,
    required this.cart,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy products
    final products = [
      Product(id: 1, name: "Nasi Goreng", price: 15000),
      Product(id: 2, name: "Es Teh Manis", price: 5000),
    ];

    return Column(
      children: [
        // List Produk
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text("Rp ${product.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () {
                      // Simulasi tambah item dengan quantity 1 dan tanpa note
                      onAddToCart(product, 1, "Pedas");
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Cart Summary (Visualisasi State Cart)
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Keranjang Belanja:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              if (cart.isEmpty) const Text("Keranjang kosong"),
              ...cart.map((item) => Text(
                  "- ${item.quantity}x ${item.name} (${item.note.isEmpty ? 'Normal' : item.note})")),
            ],
          ),
        )
      ],
    );
  }
}
