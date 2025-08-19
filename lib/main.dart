// main.dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final mediaQueryData =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  final isMobile = mediaQueryData.size.shortestSide < 600;

  if (isMobile) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'SB POS V2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: goRouter,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const double maxWidth = 1000;

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

            // 📱 & 🧑‍💻 Mobile & Tablet: full-width
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
