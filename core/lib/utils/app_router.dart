// router/app_router.dart
import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mode/presentation/screens/mode_screen.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';
import 'package:warehouse/presentation/screens/warehouse_screen.dart';
import 'package:landing_page_menu/presentation/screens/landing_page_menu_screen.dart';

class AppRouter {
  // Singleton instance
  static final AppRouter _instance = AppRouter._();

  // Getter untuk instance tunggal
  static AppRouter get instance => _instance;

  // Router yang dibuat sekali saja
  late final GoRouter router;

  // Konstruktor privat
  AppRouter._() {
    router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        if (state.matchedLocation == '/') {
          return kIsWeb ? AppRoutes.mode : AppRoutes.login;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) =>
              kIsWeb ? AppRoutes.mode : AppRoutes.login,
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.mode,
          name: AppRoutes.mode,
          builder: (context, state) => ModeScreen(appId: null),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          name: AppRoutes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/app/:appId',
          builder: (context, state) {
            final appId = int.tryParse(state.pathParameters['appId'] ?? '');
            return ModeScreen(appId: appId);
          },
          routes: [
            GoRoute(
              path: 'mode',
              name: 'app_mode',
              builder: (context, state) {
                final appId = int.tryParse(state.pathParameters['appId'] ?? '');
                return ModeScreen(appId: appId);
              },
            ),
            GoRoute(
              path: 'order',
              name: 'app_order',
              builder: (context, state) {
                final appId = int.tryParse(state.pathParameters['appId'] ?? '');
                final modeName = state.uri.queryParameters['mode'];
                return LandingPageMenuScreen(
                  appId: appId,
                  modeName: modeName,
                );
              },
            ),
            GoRoute(
              path: 'dashboard',
              name: 'app_dashboard', // ✅ nama unik
              builder: (context, state) {
                return const DashboardScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.warehouse,
          name: AppRoutes.warehouse,
          builder: (context, state) => const WarehouseScreen(),
        ),
      ],
      errorBuilder: (context, state) => ModeScreen(appId: null),
    );
  }
}
