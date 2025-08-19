// router/app_route_information_parser.dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class AppRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;

    // Jika ada path di URL, gunakan itu
    if (uri.path.isEmpty || uri.path == '/') {
      // Biarkan RouterDelegate menentukan default berdasarkan platform
      return '/';
    }

    final path = uri.path;
    if (path == AppRoutes.login) return AppRoutes.login;
    if (path == AppRoutes.dashboard) return AppRoutes.dashboard;
    if (path == AppRoutes.mode) return AppRoutes.mode;

    // Jika tidak cocok, biarkan delegate tangani
    return '/';
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}
