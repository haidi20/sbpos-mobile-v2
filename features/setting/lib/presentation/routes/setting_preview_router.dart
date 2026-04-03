import 'package:core/core.dart';
import 'package:setting/presentation/screens/help_screen.dart';
import 'package:setting/presentation/screens/notification_setting_screen.dart';
import 'package:setting/presentation/screens/payment_screen.dart';
import 'package:setting/presentation/screens/printer_screen.dart';
import 'package:setting/presentation/screens/profile_screen.dart';
import 'package:setting/presentation/screens/security_screen.dart';
import 'package:setting/presentation/screens/setting_screen.dart';
import 'package:setting/presentation/screens/store_screen.dart';

final GoRouter settingPreviewRouter = GoRouter(
  initialLocation: AppRoutes.settings,
  routes: [
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.store,
      builder: (context, state) => const StoreScreen(),
    ),
    GoRoute(
      path: AppRoutes.printer,
      builder: (context, state) => const PrinterScreen(),
    ),
    GoRoute(
      path: AppRoutes.payment,
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.notificationSetting,
      builder: (context, state) => const NotificationSettingScreen(),
    ),
    GoRoute(
      path: AppRoutes.security,
      builder: (context, state) => const SecurityScreen(),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),
  ],
);
