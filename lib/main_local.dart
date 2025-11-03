import 'package:core/core.dart';
import 'package:sbpos_v2/main.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(
        fileName: ".env.local"); // Load the local environment file
    await initializeDateFormatting('id_ID', null);
    print("✅ .env.local loaded successfully");
    runApp(const ProviderScope(child: MyApp())); // Wrap with ProviderScope
  } catch (e) {
    print("❌ Error: $e");
  }
}
