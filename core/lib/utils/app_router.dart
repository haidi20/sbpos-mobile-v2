// router/app_router.dart
import 'package:core/core.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:setting/presentation/screens/setting_screen.dart';
import 'package:dashboard/presentation/screens/report_screen.dart';
import 'package:product/presentation/screens/inventory_screen.dart';
import 'package:dashboard/presentation/screens/main_dashboard_screen.dart';
import 'package:notification/presentation/screens/notification_screen.dart';
import 'package:product/presentation/screens/product_management_screen.dart';
import 'package:transaction/presentation/screens/transaction_history_screen.dart';
import 'package:transaction/presentation/screens/transaction_screen.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._();
  static AppRouter get instance => _instance;

  late final GoRouter router;

  AppRouter._() {
    router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        if (state.matchedLocation == '/') {
          return AppRoutes.login;
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
          path: AppRoutes.notification,
          name: AppRoutes.notification,
          pageBuilder: (context, state) {
            return const MaterialPage(child: NotificationScreen());
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
          path: AppRoutes.transactionHistory,
          name: AppRoutes.transactionHistory,
          pageBuilder: (context, state) {
            return const MaterialPage(child: TransactionHistoryScreen());
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
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settings,
          pageBuilder: (context, state) {
            return const MaterialPage(child: SettingsScreen());
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
