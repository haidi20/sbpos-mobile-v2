import 'package:core/core.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // 🔄 Kembalikan orientasi saat keluar (opsional)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Perbaiki: tambahkan 'children:'
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigasi menggunakan go_router
                context.go('/landingPageMenu');
              },
              child: const Text('Go to Landing Page Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
