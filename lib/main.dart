// main.dart
import 'package:core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(); // Inisialisasi router
  }

  @override
  Widget build(BuildContext context) {
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
      routerConfig: _appRouter.router, // Gunakan go_router
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const double maxWidth = 500;

            // 💻 Desktop: Tampilan boxed dengan background abu-abu
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

            // 📱 Mobile & Tablet: Full-width, tapi dibatasi maxWidth
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
