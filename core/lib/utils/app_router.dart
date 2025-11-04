// router/app_router.dart
import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mode/presentation/screens/mode_screen.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';
import 'package:warehouse/presentation/screens/warehouse_screen.dart';
import 'package:landing_page_menu/presentation/screens/landing_page_menu_screen.dart';

class AppRouter {
  final GoRouter _router = GoRouter(
    // Gunakan initial location tetap, lalu redirect
    initialLocation: '/',

    redirect: (context, state) {
      // Gunakan `matchedLocation` — ini aman di semua versi GoRouter baru
      if (state.matchedLocation == '/') {
        return kIsWeb ? AppRoutes.mode : AppRoutes.login;
      }
      return null;
    },

    routes: [
      // Root route — akan di-redirect
      GoRoute(
        path: '/',
        redirect: (context, state) => kIsWeb ? AppRoutes.mode : AppRoutes.login,
      ),

      // Login
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Mode tanpa appId
      GoRoute(
        path: AppRoutes.mode,
        name: AppRoutes.mode,
        builder: (context, state) => ModeScreen(appId: null),
      ),

      // Dashboard (opsional: bisa juga jadi child dari /app/:appId)
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),

      // ⚠️ HAPUS route `/app` yang berdiri sendiri karena bentrok dengan `/app/:appId`
      // ❌ Jangan gunakan ini:
      // GoRoute(path: '/app', ...)

      // ✅ Ganti dengan route dinamis: /app/:appId
      GoRoute(
        path: '/app/:appId',
        builder: (context, state) {
          // Default behavior: tampilkan ModeScreen jika tidak ada subroute
          final appId = int.tryParse(state.pathParameters['appId'] ?? '');
          return ModeScreen(appId: appId);
        },
        routes: [
          // /app/:appId/mode
          GoRoute(
            path: 'mode',
            builder: (context, state) {
              final appId = int.tryParse(state.pathParameters['appId'] ?? '');
              return ModeScreen(appId: appId);
            },
          ),
          // /app/:appId/order
          GoRoute(
            path: 'order',
            builder: (context, state) {
              final appId = int.tryParse(state.pathParameters['appId'] ?? '');
              final modeName = state.uri.queryParameters['mode'];
              return LandingPageMenuScreen(
                appId: appId,
                modeName: modeName,
              );
            },
          ),

          // /app/:appId/dashboard
          GoRoute(
            path: 'dashboard',
            name: 'warehouse', // ✅ WAJIB beri name!
            builder: (context, state) {
              // final appId = int.tryParse(state.pathParameters['appId'] ?? '');
              return const DashboardScreen();
            },
          ),
        ],
      ),
      // /app/:appId/warehouse
      GoRoute(
        path: AppRoutes.warehouse,
        name: AppRoutes.warehouse,
        builder: (context, state) => const WarehouseScreen(),
      ),
    ],

    errorBuilder: (context, state) => ModeScreen(appId: null),
  );

  GoRouter get router => _router;
}
