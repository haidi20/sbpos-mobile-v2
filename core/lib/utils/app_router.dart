// router.dart
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';
import 'package:landing_page_menu/presentation/screens/landing_page_menu_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.landingPageMenu,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.landingPageMenu,
        builder: (context, state) => LandingPageMenuScreen(),
      ),
    ],
    // Opsional: tambahkan redirect atau error handling
    // redirect: (context, state) {
    //   // Misalnya cek auth status
    //   final isLoggedIn = ref.read(authProvider).isLoggedIn;
    //   final isLoggingIn = state.location == AppRoutes.login;
    //
    //   if (!isLoggedIn && !isLoggingIn) return AppRoutes.login;
    //   if (isLoggedIn && isLoggingIn) return AppRoutes.dashboard;
    //   return null;
    // },
  );
});
