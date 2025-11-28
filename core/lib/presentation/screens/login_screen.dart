import 'package:core/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    ),
  );
}
// -----------------------------------------------------------------------------
// LOGIN SCREEN (ConsumerStatefulWidget)
// -----------------------------------------------------------------------------

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  // The Controller
  late final AuthController _authController;

  // Local UI State (Keep purely visual state local)
  bool _obscureText = true;
  bool _rememberMe = false;

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Styles
  static const Color sbBlue = Color(0xFF1E40AF);
  static const Color sbOrange = Color(0xFFF97316);
  static const Color sbBg = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    // Initialize AuthController
    // We pass 'ref' and 'context' to it as requested
    _authController = AuthController(ref, context);

    // Animation Setup
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _authController.dispose(); // Important: Dispose text controllers
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider to update UI when loading changes
    // final authState = ref.watch(authViewModelProvider);
    // final isLoading = authState.isLoading;
    const bool isLoading = false;

    return Scaffold(
      backgroundColor: sbBg,
      body: Stack(
        children: [
          // --- Background Blobs ---
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlob(_scaleAnimation, sbBlue),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBlob(_scaleAnimation, sbOrange),
          ),

          // --- Main Content ---
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: sbBlue,
                        letterSpacing: -1.0,
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        TextSpan(text: 'SB'),
                        TextSpan(
                          text: 'POS',
                          style: TextStyle(color: sbOrange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Solusi Pintar Bisnis Anda',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),

                  // Login Card
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Selamat Datang Kembali',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Input (Bound to Controller)
                        _buildTextField(
                          controller: _authController.emailController,
                          hintText: 'ID / Email',
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 16),

                        // Password Input (Bound to Controller)
                        _buildTextField(
                          controller: _authController.passwordController,
                          hintText: 'Kata Sandi',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),

                        const SizedBox(height: 8),

                        // Options Row
                        _buildOptionsRow(),

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            // Call the controller's onLogin method
                            onPressed: isLoading
                                ? null
                                : () => _authController.onLogin(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sbBlue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: sbBlue.withOpacity(0.7),
                              elevation: 4,
                              shadowColor: Colors.blue.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Masuk Aplikasi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'SB POS App v1.2.0 • Build 20231024',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildBlob(Animation<double> animation, Color color) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                activeColor: sbBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Colors.grey),
                onChanged: (val) {
                  setState(() {
                    _rememberMe = val ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Ingat Saya',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Lupa Password?',
            style: TextStyle(
              color: sbBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              offset: const Offset(0, 1),
              blurRadius: 2,
            )
          ]),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscureText,
        style: const TextStyle(color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9CA3AF),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: sbBlue, width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }
}
