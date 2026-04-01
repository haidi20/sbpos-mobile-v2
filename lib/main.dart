import 'package:core/core.dart';
import 'package:sbpos_v2/app_database_schema.dart';
import 'package:sbpos_v2/app_repository_overrides.dart';
import 'package:sbpos_v2/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env.local');
  } catch (_) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Both env files are optional in local/test runs.
    }
  }

  configureAppDatabaseSchema();

  runApp(
    ProviderScope(
      overrides: buildAppRepositoryOverrides(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: Container(
                      color: Colors.white,
                      child: child,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                    ),
                  ),
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
