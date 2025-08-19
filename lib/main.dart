// main.dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
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
            const double maxWidth = 1000; // 🔁 Ubah di sini: 800, 1000, dll

            if (constraints.maxWidth > maxWidth) {
              return Row(
                children: [
                  // Kiri: light gray
                  Expanded(
                    child: Container(
                      color: Colors.grey[200], // Light gray
                    ),
                  ),
                  // Tengah: konten utama
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: Container(
                      color: Colors.white,
                      child: child,
                    ),
                  ),
                  // Kanan: light gray
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                    ),
                  ),
                ],
              );
            } else {
              // Di layar kecil: tanpa padding, full width
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  color: Colors.white,
                  child: child,
                ),
              );
            }
          },
        );
      },
    );
  }
}
