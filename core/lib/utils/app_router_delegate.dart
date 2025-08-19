// router/app_router_delegate.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:core/core.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:dashboard/presentation/screens/dashboard_screen.dart';
import 'package:landing_page_menu/presentation/screens/landing_page_menu_screen.dart';
import 'package:mode/presentation/screens/mode_screen.dart';

class AppRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String? _currentRoute;

  AppRouterDelegate() {
    // Tentukan default route saat inisialisasi
    _currentRoute = _getDefaultRoute();
  }

  // Tentukan default berdasarkan platform
  String _getDefaultRoute() {
    if (kIsWeb) {
      return AppRoutes.mode;
    } else {
      return AppRoutes.login;
    }
  }

  @override
  String get currentConfiguration => _currentRoute ?? AppRoutes.mode;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (_currentRoute == AppRoutes.landingPageMenu)
          const MaterialPage(
            key: ValueKey(AppRoutes.landingPageMenu),
            child: LandingPageMenuScreen(),
          ),
        if (_currentRoute == AppRoutes.login)
          const MaterialPage(
            key: ValueKey(AppRoutes.login),
            child: LoginScreen(),
          ),
        if (_currentRoute == AppRoutes.dashboard)
          const MaterialPage(
            key: ValueKey(AppRoutes.dashboard),
            child: DashboardScreen(),
          ),
        if (_currentRoute == AppRoutes.mode)
          MaterialPage(
            key: const ValueKey(AppRoutes.mode),
            child: ModeScreen(),
          ),
        // Fallback: jika route tidak dikenali
        if (_currentRoute == null || !_isValidRoute(_currentRoute!))
          MaterialPage(
            key: const ValueKey('Fallback'),
            child: ModeScreen(), // atau halaman 404
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        // Optional: kembali ke landing page atau atur ulang
        setNewRoutePath(AppRoutes.landingPageMenu);
        return true;
      },
    );
  }

  // Cek apakah route valid
  bool _isValidRoute(String route) {
    return <String>[
      AppRoutes.landingPageMenu,
      AppRoutes.login,
      AppRoutes.dashboard,
      AppRoutes.mode,
    ].contains(route);
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    if (_isValidRoute(configuration)) {
      _currentRoute = configuration;
    } else {
      // Jika route tidak valid, gunakan default berdasarkan platform
      _currentRoute = _getDefaultRoute();
    }
    notifyListeners();
  }
}
