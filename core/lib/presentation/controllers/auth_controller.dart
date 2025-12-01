// auth_controller.dart

import 'package:core/core.dart';
import 'package:core/presentation/providers/auth_provider.dart';
import 'package:core/presentation/view_models/auth.vm.dart';

class AuthController {
  AuthController(this.ref, this.context);

  // static final Logger _logger = Logger('AuthController');

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

    context.go(AppRoutes.dashboard);

    // _authViewModel
    //     .storeLogin(
    //   email: email,
    //   password: password,
    // )
    //     .then((_) {
    //   final state = ref.read(authViewModelProvider);
    //   if (state.isAuthenticated) {
    //     if (context.mounted) {
    //       context.go(AppRoutes.dashboard);
    //     }
    //   } else if (state.error != null) {
    //     if (context.mounted) {
    //       showErrorSnackBar(context, state.error!);
    //     }
    //   }
    // });
  }

  void onLogout() {
    _authViewModel.logout();
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
