import 'package:core/core.dart';
import 'package:dashboard/presentation/widgets/main_header.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';
import 'package:dashboard/presentation/view_models/dashboard.state.dart';
import 'package:dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dashboard/presentation/controllers/dashboard.controller.dart';
import 'package:transaction/presentation/screens/transaction_history.screen.dart';
import 'package:dashboard/presentation/widgets/bottom_navigation_bar_custom.dart';
import 'package:dashboard/presentation/component/floating_action_button_custom.dart';

class MainDashboardScreen extends ConsumerStatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  ConsumerState<MainDashboardScreen> createState() =>
      _MainDashboardScreenState();
}

class _MainDashboardScreenState extends ConsumerState<MainDashboardScreen> {
  late DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(ref, context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final viewModel = ref.read(dashboardViewModelProvider.notifier);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.sbBg,
      // Jangan naik saat keyboard muncul
      resizeToAvoidBottomInset: false,
      // Biarkan body menggambar sampai ke belakang bottom bar untuk tampilan mulus
      extendBody: true,
      // --- 2. SETTING HEADER (APPBAR) ---
      // Penting: extendBodyBehindAppBar true agar konten bisa discroll
      // melewati belakang header, sehingga efek BLUR terlihat.
      // extendBodyBehindAppBar: true,
      appBar: const CustomHeader(),
      // Body
      body: state.activeTab == AppTab.dashboard
          ? const DashboardScreen()
          : const TransactionHistoryScreen(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isKeyboardOpen
          ? null
          : FloatingActionButtonCustom(
              onAddClick: () => _controller.onAddClick(),
            ),
      // 2. Bottom Navigation Bar
      bottomNavigationBar: isKeyboardOpen
          ? const SizedBox.shrink()
          : BottomNavigationBarCustom(
              activeTab: state.activeTab,
              onTabChange: viewModel.onTabChange,
            ),
    );
  }
}
