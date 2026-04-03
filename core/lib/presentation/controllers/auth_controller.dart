import 'package:core/core.dart';
import 'package:core/presentation/providers/auth_provider.dart';
import 'package:core/presentation/view_models/auth.vm.dart';

class AuthController {
  AuthController(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  late final AuthViewModel _authViewModel =
      ref.read(authViewModelProvider.notifier);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> onLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showErrorSnackBar(context, 'Email dan password harus diisi');
      return;
    }

    if (password.length < 6) {
      showErrorSnackBar(context, 'Password minimal 6 karakter');
      return;
    }

    final isSuccess = await _authViewModel.storeLogin(
      email: email,
      password: password,
    );

    if (!context.mounted) {
      return;
    }

    final state = ref.read(authViewModelProvider);
    if (isSuccess && state.isAuthenticated) {
      context.go(AppRoutes.dashboard);
      return;
    }

    showErrorSnackBar(
      context,
      state.error ?? 'Login gagal, silakan coba lagi',
    );
  }

  void onForgotPassword() {
    showSuccessSnackBar(
      context,
      'Silakan hubungi Admin untuk proses reset password.',
    );
  }

  Future<void> onLogout() async {
    await _authViewModel.logout();
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
