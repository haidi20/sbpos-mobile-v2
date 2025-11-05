// login_controller.dart

import 'package:core/core.dart';
import 'package:core/presentation/providers/auth_provider.dart';
import 'package:core/presentation/viewmodels/auth_viewmodel.dart';

class LoginController {
  LoginController(this.ref, this.context);

  static final Logger _logger = Logger('LoginController');

  final WidgetRef ref;
  final BuildContext context;

  final TextEditingController emailController =
      TextEditingController(text: 'kasir@hadi.com');
  final TextEditingController passwordController =
      TextEditingController(text: 'hadi55');

  void handleLogin() {
    final email = emailController.text;
    final password = passwordController.text;
    AuthViewModel authViewModel = ref.read(authViewModelProvider.notifier);

    if (email.isEmpty || password.isEmpty) {
      showErrorSnackBar(context, 'Email dan password harus diisi');
      return;
    }

    authViewModel.storeLogin(
      email: email,
      password: password,
    );
  }

  void observeAuthState() {
    final state = ref.watch(authViewModelProvider);

    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showErrorSnackBar(context, state.error!);
        }
      });
    }

    if (state.user != null) {
      _logger.info('redirect ke landing page');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(AppRoutes.landingPageMenu);
        }
      });
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
