// main.dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Opsional: lock orientation
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.landscapeRight,
  // ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate();
    _routeInformationParser = AppRouteInformationParser();
  }

  @override
  void dispose() {
    // Jika ada listener atau stream, dispose di sini
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SB POS V2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      routeInformationParser: _routeInformationParser,
      routerDelegate: _routerDelegate,
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation:
            const RouteInformation(location: AppRoutes.landingPageMenu),
      ),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const double maxWidth = 500;

            // 💻 Desktop: tampilkan layout boxed (sisi abu-abu)
            if (constraints.maxWidth > 1200) {
              return Row(
                children: [
                  Expanded(child: Container(color: Colors.grey[200])),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: Container(color: Colors.white, child: child),
                  ),
                  Expanded(child: Container(color: Colors.grey[200])),
                ],
              );
            }

            // 📱 Mobile & Tablet: full-width dalam batas maxWidth
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Container(
                color: Colors.white,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
