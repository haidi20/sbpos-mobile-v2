import 'package:flutter/material.dart';
import 'package:dashboard/presentation/view_models/dashboard.state.dart';

class BottomNavigationBarCustom extends StatelessWidget {
  final AppTab activeTab;
  final ValueChanged<AppTab> onTabChange;

  const BottomNavigationBarCustom({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 20,
        shadowColor: Colors.black.withOpacity(0.05),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTabItem(
                context,
                icon: Icons.home_outlined,
                label: "Dashboard",
                tab: AppTab.dashboard,
                isActive: activeTab == AppTab.dashboard,
                onTap: () => onTabChange(AppTab.dashboard),
              ),
              const SizedBox(width: 64),
              _buildTabItem(
                context,
                icon: Icons.list_alt,
                label: "Orders",
                tab: AppTab.orders,
                isActive: activeTab == AppTab.orders,
                onTap: () => onTabChange(AppTab.orders),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required AppTab tab,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    // text-[#1e40af] -> Color(0xFF1E40AF)
    // text-gray-400 -> Colors.grey[400]
    final color = isActive ? const Color(0xFF1E40AF) : Colors.grey[400];

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
              // strokeWidth simulasi dengan weight (jika pakai font icon variasi)
              // atau biarkan default
            ),
            const SizedBox(height: 4), // space-y-1
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12, // text-xs
                fontWeight: FontWeight.w500, // font-medium
              ),
            )
          ],
        ),
      ),
    );
  }
}
