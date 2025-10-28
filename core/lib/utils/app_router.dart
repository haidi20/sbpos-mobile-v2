// router/app_router.dart
import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mode/presentation/screens/mode_screen.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:outlet/presentation/screens/outlet_screen.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';
import 'package:landing_page_menu/presentation/screens/landing_page_menu_screen.dart';

class AppRouter {
  final GoRouter _router = GoRouter(
    // Tentukan initial location berdasarkan platform
    initialLocation: kIsWeb ? AppRoutes.mode : AppRoutes.login,

    // Parser untuk handle dynamic route
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/app/:appId/order',
        builder: (context, state) {
          final String? appIdParam = state.pathParameters['appId'];
          final int? appId = int.tryParse(appIdParam ?? '');
          final String? modeName = state.uri.queryParameters['mode'];
          return LandingPageMenuScreen(
            appId: appId,
            modeName: modeName,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.mode,
        builder: (context, state) => ModeScreen(appId: null),
      ),
      // Dynamic route: /app/123/mode
      GoRoute(
        path: '/app/:appId/mode',
        builder: (context, state) {
          final String? appIdParam = state.pathParameters['appId'];
          final int? appId = int.tryParse(appIdParam ?? '');
          return ModeScreen(appId: appId);
        },
      ),
      GoRoute(
        path: '/app',
        builder: (context, state) {
          return OutletScreen();
        },
      ),
    ],

    // Fallback: jika route tidak ditemukan
    errorBuilder: (context, state) => ModeScreen(appId: null),
  );

  GoRouter get router => _router;
}
