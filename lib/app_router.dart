import 'package:core/presentation/screens/coming_soon.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:core/presentation/screens/webhook_realtime_test_screen.dart';
import 'package:core/utils/app_routes.dart';
import 'package:dashboard/presentation/screens/main_dashboard_screen.dart';
import 'package:dashboard/presentation/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification/presentation/screens/notification_screen.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/presentation/screens/inventory_screen.dart';
import 'package:product/presentation/screens/packet_management.screen.dart';
import 'package:product/presentation/screens/packet_management_form.screen.dart';
import 'package:product/presentation/screens/product_management.screen.dart';
import 'package:setting/presentation/screens/help_screen.dart';
import 'package:setting/presentation/screens/notification_setting_screen.dart';
import 'package:setting/presentation/screens/payment_screen.dart';
import 'package:setting/presentation/screens/printer_screen.dart';
import 'package:setting/presentation/screens/profile_screen.dart';
import 'package:setting/presentation/screens/security_screen.dart';
import 'package:setting/presentation/screens/setting_screen.dart';
import 'package:setting/presentation/screens/store_screen.dart';
import 'package:transaction/presentation/screens/close_cashier.screen.dart';
import 'package:transaction/presentation/screens/open_cashier.screen.dart';
import 'package:transaction/presentation/screens/transaction_history.screen.dart';
import 'package:transaction/presentation/screens/transaction_pos.screen.dart';
import 'package:transaction/presentation/widgets/open_cashier_guard.dart';
import 'package:expense/presentation/screens/expense_screen.dart';


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
            return _guardedPage(
              MainDashboardScreen(
                ordersPage: const TransactionHistoryScreen(),
                showOrdersInitially: state.uri.queryParameters['tab'] == 'orders',
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.openCashier,
          name: AppRoutes.openCashier,
          pageBuilder: (context, state) {
            return const MaterialPage(child: OpenCashierScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.closeCashier,
          name: AppRoutes.closeCashier,
          pageBuilder: (context, state) {
            return const MaterialPage(child: CloseCashierScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.notification,
          name: AppRoutes.notification,
          pageBuilder: (context, state) {
            return _guardedPage(const NotificationScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.transactionPos,
          name: AppRoutes.transactionPos,
          pageBuilder: (context, state) {
            return _guardedPage(const TransactionPosScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.transactionHistory,
          name: AppRoutes.transactionHistory,
          pageBuilder: (context, state) {
            return _guardedPage(const TransactionHistoryScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.report,
          name: AppRoutes.report,
          pageBuilder: (context, state) {
            return _guardedPage(const ReportsScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.inventory,
          name: AppRoutes.inventory,
          pageBuilder: (context, state) {
            return _guardedPage(const InventoryScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.productManagement,
          name: AppRoutes.productManagement,
          pageBuilder: (context, state) {
            return _guardedPage(const ProductManagementScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.packetManagement,
          name: AppRoutes.packetManagement,
          pageBuilder: (context, state) {
            return _guardedPage(const PacketManagementScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.packetManagementForm,
          name: AppRoutes.packetManagementForm,
          pageBuilder: (context, state) {
            final extra = state.extra;
            final packetEntity = extra is PacketEntity ? extra : null;
            return _guardedPage(
              PacketManagementFormScreen(packetEntity: packetEntity),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settings,
          pageBuilder: (context, state) {
            return _guardedPage(const SettingsScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: AppRoutes.profile,
          pageBuilder: (context, state) {
            return _guardedPage(const ProfileScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.store,
          name: AppRoutes.store,
          pageBuilder: (context, state) {
            return _guardedPage(const StoreScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.security,
          name: AppRoutes.security,
          pageBuilder: (context, state) {
            return _guardedPage(const SecurityScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.payment,
          name: AppRoutes.payment,
          pageBuilder: (context, state) {
            return _guardedPage(const PaymentScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.printer,
          name: AppRoutes.printer,
          pageBuilder: (context, state) {
            return _guardedPage(const PrinterScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.notificationSetting,
          name: AppRoutes.notificationSetting,
          pageBuilder: (context, state) {
            return _guardedPage(const NotificationSettingScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.help,
          name: AppRoutes.help,
          pageBuilder: (context, state) {
            return _guardedPage(const HelpScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.comingSoonScreen,
          name: AppRoutes.comingSoonScreen,
          pageBuilder: (context, state) {
            return const MaterialPage(child: ComingSoonScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.webhookTest,
          name: AppRoutes.webhookTest,
          pageBuilder: (context, state) {
            return const MaterialPage(child: WebhookRealtimeTestScreen());
          },
        ),
        GoRoute(
          path: AppRoutes.expense,
          name: AppRoutes.expense,
          pageBuilder: (context, state) {
            return _guardedPage(const ExpenseScreen());
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

  MaterialPage<void> _guardedPage(Widget child) {
    return MaterialPage<void>(
      child: OpenCashierGuard(child: child),
    );
  }
}
