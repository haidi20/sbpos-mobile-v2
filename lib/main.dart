// main.dart
import 'package:core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Try to load local env first to avoid 404s in web dev; fallback to .env
  try {
    await dotenv.load(fileName: '.env.local');
  } catch (_) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // both env files missing — continue without dotenv
    }
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan instance singleton dari AppRouter
    final router = AppRouter.instance.router;

    return MaterialApp.router(
      title: 'SB POS V2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppSetting.primaryColor,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: router,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const double maxWidth = 500;

            if (constraints.maxWidth > 1200) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: Container(color: Colors.white, child: child),
                  ),
                  Expanded(child: Container(color: Colors.grey[200])),
                ],
              );
            }

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
