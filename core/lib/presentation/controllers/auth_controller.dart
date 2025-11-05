// auth_controller.dart

import 'package:core/core.dart';
import 'package:core/presentation/providers/auth_provider.dart';
import 'package:core/presentation/viewmodels/auth_viewmodel.dart';

class AuthController {
  AuthController(this.ref, this.context);

  static final Logger _logger = Logger('AuthController');

  final WidgetRef ref;
  final BuildContext context;

  late final AuthViewModel _authViewModel =
      ref.read(authViewModelProvider.notifier);

  final TextEditingController emailController =
      TextEditingController(text: 'kasir@hadi.com');
  final TextEditingController passwordController =
      TextEditingController(text: 'hadi55');

  void onLogin() {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showErrorSnackBar(context, 'Email dan password harus diisi');
      return;
    }

    _authViewModel.storeLogin(email: email, password: password);
  }

  void onLogout() {
    _authViewModel.logout();
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
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
