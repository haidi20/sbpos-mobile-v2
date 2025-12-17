// router/app_router.dart
import 'package:core/core.dart';
import 'package:core/presentation/screens/coming_soon.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:setting/presentation/screens/setting_screen.dart';
// Import Screens Pengaturan yang Baru
import 'package:setting/presentation/screens/help_screen.dart';
import 'package:setting/presentation/screens/store_screen.dart';
import 'package:setting/presentation/screens/payment_screen.dart';
import 'package:setting/presentation/screens/printer_screen.dart';
import 'package:setting/presentation/screens/profile_screen.dart';
import 'package:setting/presentation/screens/security_screen.dart';
import 'package:setting/presentation/screens/notification_setting_screen.dart';
// Akhir Import Screens Pengaturan

import 'package:dashboard/presentation/screens/report_screen.dart';
import 'package:product/presentation/screens/inventory_screen.dart';
import 'package:dashboard/presentation/screens/main_dashboard_screen.dart';
import 'package:notification/presentation/screens/notification_screen.dart';
import 'package:product/presentation/screens/product_management.screen.dart';
import 'package:transaction/presentation/screens/transaction_pos.screen.dart';
import 'package:transaction/presentation/screens/transaction_history.screen.dart';

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
          path: AppRoutes.transactionPos,
          name: AppRoutes.transactionPos,
          pageBuilder: (context, state) {
            return const MaterialPage(child: TransactionPosScreen());
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
        // Rute Pengaturan Utama (SettingScreen)
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settings,
          pageBuilder: (context, state) {
            return const MaterialPage(child: SettingsScreen());
          },
        ),

        // --- Rute-rute Tambahan untuk Modul Setting ---

        GoRoute(
          path: AppRoutes.profile,
          name: AppRoutes.profile,
          pageBuilder: (context, state) {
            return const MaterialPage(child: ProfileScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.store,
          name: AppRoutes.store,
          pageBuilder: (context, state) {
            return const MaterialPage(child: StoreScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.security,
          name: AppRoutes.security,
          pageBuilder: (context, state) {
            return const MaterialPage(child: SecurityScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.payment,
          name: AppRoutes.payment,
          pageBuilder: (context, state) {
            return const MaterialPage(child: PaymentScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.printer,
          name: AppRoutes.printer,
          pageBuilder: (context, state) {
            return const MaterialPage(child: PrinterScreen());
          },
        ),
        // Gunakan alias jika nama AppRoutes.notificationConflicting dengan yang sudah ada
        GoRoute(
          path: AppRoutes.notificationSetting,
          name: AppRoutes.notificationSetting,
          pageBuilder: (context, state) {
            return const MaterialPage(child: NotificationSettingScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.help,
          name: AppRoutes.help,
          pageBuilder: (context, state) {
            return const MaterialPage(child: HelpScreen());
          },
        ),

        // --- Akhir Rute-rute Modul Setting ---

        GoRoute(
          path: AppRoutes.comingSoonScreen,
          name: AppRoutes.comingSoonScreen,
          pageBuilder: (context, state) {
            return const MaterialPage(child: ComingSoonScreen());
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
