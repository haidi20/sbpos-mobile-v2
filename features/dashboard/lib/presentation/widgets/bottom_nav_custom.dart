import 'package:flutter/material.dart';

// Enum untuk Tab (sesuai kode React Anda)
enum TabItem { dashboard, order }

class BottomNavCustom extends StatelessWidget {
  final TabItem activeTab;
  final Function(TabItem) onTabChange;

  const BottomNavCustom({
    Key? key,
    required this.activeTab,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Container ini mereplikasi class:
    // "fixed bottom-0 left-0 right-0 h-20 bg-white shadow-... rounded-t-3xl"
    return Container(
      height: 80, // h-20 (80px)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24)), // rounded-t-3xl
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // shadow color
            blurRadius: 6, // shadow blur
            offset: const Offset(0, -4), // shadow direction (upwards)
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 48.0), // px-12 equivalent
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Dashboard Tab ---
            _buildNavItem(
              context: context,
              item: TabItem.dashboard,
              icon: Icons.dashboard_outlined, // LayoutDashboard icon
              label: "Dashboard",
            ),

            // Spacer kosong di tengah untuk memberi ruang pada FAB
            const SizedBox(width: 48),

            // --- Order Tab ---
            _buildNavItem(
              context: context,
              item: TabItem.order,
              icon: Icons.shopping_bag_outlined, // ShoppingBag icon
              label: "Order",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required TabItem item,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = activeTab == item;

    // Warna aktif (Blue-700) dan tidak aktif (Gray-400)
    final Color color = isActive ? Colors.blue[700]! : Colors.grey[400]!;

    return GestureDetector(
      onTap: () => onTabChange(item),
      behavior: HitTestBehavior.opaque, // Agar area klik lebih responsif
      child: SizedBox(
        width: 64, // w-16
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
              // Stroke width simulasi bisa pakai IconTheme, tapi standard Icon sudah cukup
            ),
            const SizedBox(height: 4), // space-y-1
            Text(
              label,
              style: TextStyle(
                fontSize: 12, // text-xs
                fontWeight: FontWeight.w500, // font-medium
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Khusus untuk FAB dengan Gradient (Karena FAB bawaan tidak support gradient langsung)
class GradientFab extends StatelessWidget {
  final VoidCallback onPressed;

  const GradientFab({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64, // w-16
      height: 64, // h-16
      child: FloatingActionButton(
        onPressed: onPressed,
        elevation: 8, // shadow-lg
        backgroundColor:
            Colors.transparent, // Transparan agar gradient terlihat
        shape: const CircleBorder(),
        child: Ink(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFA500), // Primary Orange (Approximation)
                Color(0xFFE06C10), // #e06c10 (Sesuai kode React)
              ],
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Icon(
              Icons.add, // Plus Icon
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
