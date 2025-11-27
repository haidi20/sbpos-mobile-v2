// router/app_router.dart
import 'package:core/core.dart';
import 'package:mode/presentation/screens/mode_screen.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';
import 'package:warehouse/presentation/screens/warehouse_screen.dart';
import 'package:landing_page_menu/presentation/screens/landing_page_menu_screen.dart';

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

        // ✅ Perbaiki route /app/:appId dengan pageBuilder
        GoRoute(
          path: '/app/:appId',
          name: 'app', // ✅ Beri nama unik
          pageBuilder: (context, state) {
            final appId = int.tryParse(state.pathParameters['appId'] ?? '');
            return MaterialPage(child: ModeScreen(appId: appId));
          },
          routes: [
            GoRoute(
              path: '/mode',
              pageBuilder: (context, state) {
                final appId = int.tryParse(state.pathParameters['appId'] ?? '');
                return MaterialPage(child: ModeScreen(appId: appId));
              },
            ),
            GoRoute(
              path: '/order',
              pageBuilder: (context, state) {
                final appId = int.tryParse(state.pathParameters['appId'] ?? '');
                final modeName = state.uri.queryParameters['mode'];
                // print('>>> Navigasi ke order: appId=$appId, mode=$modeName');
                return MaterialPage(
                  child: LandingPageMenuScreen(
                    appId: appId,
                    modeName: modeName,
                  ),
                );
              },
            ),
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) {
                return const MaterialPage(child: DashboardScreen());
              },
            ),
          ],
        ),

        GoRoute(
          path: AppRoutes.warehouse,
          name: AppRoutes.warehouse,
          pageBuilder: (context, state) =>
              const MaterialPage(child: WarehouseScreen()),
        ),
      ],
      errorBuilder: (context, state) => ModeScreen(appId: null),
    );
  }
}
