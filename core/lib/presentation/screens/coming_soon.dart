import 'package:core/core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halaman Dalam Pengembangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.sbBg,
        // Menggunakan Inter font global
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const ComingSoonScreen(),
    );
  }
}

// Widget Utama dengan Animasi
class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with SingleTickerProviderStateMixin {
  // Animation for the Gear Spin
  late AnimationController _spinController;
  // Animation for the Pulse Glow (implicitly handled by repeating the spin)

  @override
  void initState() {
    super.initState();
    // Initialize spin controller for the gear icon
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Simulate animate-spin-slow
    )..repeat(); // Repeat indefinitely
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      debugPrint('Simulasi: Kembali ke halaman sebelumnya...');
    }
  }

  // --- Widget untuk Animasi Putar Gigi ---
  Widget _buildAnimatedGear() {
    return RotationTransition(
      turns: _spinController,
      child: const Icon(
        LucideIcons.settings,
        size: 28,
        color: Colors.white,
      ),
    );
  }

  // --- Widget untuk Glow Background ---
  Widget _buildBackgroundGlow(BuildContext context) {
    // Simulasi blob background (dari komponen Background sebelumnya)
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.sbBg,
      child: Stack(
        children: [
          // Blob 1 (top-0 -left-10 w-96 h-96 bg-sb-blue/10)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sbBlue.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          // Blob 2 (bottom right)
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sbOrange.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengganti background dengan Stack yang lebih simpel
      body: Stack(
        children: [
          _buildBackgroundGlow(context),

          // Main Content - Centered
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512), // max-w-2xl
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated Illustration (use larger box to avoid clipping the gear)
                    Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              LucideIcons.construction,
                              size: 90,
                              color: AppColors.sbBlue,
                            ),

                            // Animated Gear Accent positioned inside larger box
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.sbOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.sbBg, width: 3),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: _buildAnimatedGear(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Headlines
                    Column(
                      children: [
                        Text(
                          'Segera Hadir',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: AppColors.sbBlue,
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 6,
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.sbOrange,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Text(
                          'Halaman ini sedang dalam tahap pengembangan.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.sbGray,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),

                    // Back Button
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: ElevatedButton.icon(
                        onPressed: () => _goBack(context),
                        icon: const Icon(LucideIcons.arrowLeft, size: 20),
                        label: const Text('Kembali'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sbBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 10,
                          shadowColor: AppColors.sbBlue.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
