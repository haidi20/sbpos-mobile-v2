// router/app_router.dart
import 'package:core/core.dart';
import 'package:dashboard/presentation/screens/inventory_screen.dart';
import 'package:dashboard/presentation/screens/product_management_screen.dart';
import 'package:dashboard/presentation/screens/report_screen.dart';
import 'package:mode/presentation/screens/mode_screen.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:product/presentation/screens/product_screen.dart';
import 'package:transaction/presentation/screens/transaction_screen.dart';
import 'package:dashboard/presentation/screens/main_dashboard_screen.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._();
  static AppRouter get instance => _instance;

  late final GoRouter router;

  AppRouter._() {
    router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        if (state.matchedLocation == '/') {
          return AppRoutes.dashboard;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => AppRoutes.login,
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.login,
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginScreen()),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          name: AppRoutes.dashboard,
          pageBuilder: (context, state) {
            return const MaterialPage(child: MainDashboardScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.transaction,
          name: AppRoutes.transaction,
          pageBuilder: (context, state) {
            return const MaterialPage(child: TransactionScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.product,
          name: AppRoutes.product,
          pageBuilder: (context, state) {
            return const MaterialPage(child: ProductScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.report,
          name: AppRoutes.report,
          pageBuilder: (context, state) {
            return const MaterialPage(child: ReportsScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.inventory,
          name: AppRoutes.inventory,
          pageBuilder: (context, state) {
            return const MaterialPage(child: InventoryScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.productManagement,
          name: AppRoutes.productManagement,
          pageBuilder: (context, state) {
            return const MaterialPage(child: ProductManagementScreen());
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
  }
}
