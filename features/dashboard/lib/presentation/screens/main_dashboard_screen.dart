import 'package:core/core.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';
import 'package:dashboard/presentation/widgets/bottom_navigation_bar_custom.dart';
import 'package:dashboard/presentation/widgets/floating_action_button_custom.dart';

// 2. Widget Utama Halaman (Contoh Implementasi)
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  AppTab _activeTab = AppTab.dashboard;
  final _logger = Logger('MainDashboardScreen');

  void _onTabChange(AppTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _onAddClick() {
    _logger.info("Floating Action Button Clicked");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC), // Sesuai warna border di React (#f8fafc)

      // Body
      body: _activeTab == AppTab.dashboard
          ? const DashboardScreen()
          : const Center(
              child: Text(
                "Orders View",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),

      // --- BAGIAN INI YANG PENTING (MENGGANTIKAN BottomNav React) ---

      // 1. Tombol Tengah (Floating Action Button)
      // Lokasi: centerDocked membuat tombol "duduk" di bibir BottomAppBar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButtonCustom(
        onAddClick: _onAddClick,
      ),

      // 2. Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBarCustom(
        activeTab: _activeTab,
        onTabChange: _onTabChange,
      ),
    );
  }
}
