// lib/presentation/screens/login_screen.dart
import 'package:core/core.dart';
import 'package:core/presentation/providers/auth_provider.dart';
import 'package:core/presentation/widgets/message_snackbar.dart';
import 'package:core/presentation/viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void _onStoreLogin(
    AuthViewModel viewModel,
    String username,
    String password,
  ) {
    if (username.isEmpty || password.isEmpty) {
      // Anda bisa tampilkan snackbar langsung di sini
      // Tapi sebaiknya lewat ViewModel — atau tampilkan langsung karena ini validasi UI
      // Di sini kita tampilkan langsung
      // (karena bukan error dari repository)
    } else {
      viewModel.storeLogin(
        username: username,
        password: password,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);
    final viewModel = ref.read(authViewModelProvider.notifier);

    final usernameController = TextEditingController(text: 'kasir@hadi.com');
    final passwordController = TextEditingController(text: 'hadi55');

    // Tampilkan Snackbar jika ada error
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showErrorSnackBar(context, state.error!);
        }
      });
    }

    // Tampilkan Snackbar sukses & navigasi
    if (state.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showSuccessSnackBar(context, 'Berhasil login');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.push(AppRoutes.landingPageMenu);
            }
          });
        }
      });
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: AppSetting.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Selamat Datang ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppSetting.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(
                        Icons.person,
                        color: AppSetting.primaryColor,
                      ),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppSetting.primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppSetting.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(
                        Icons.lock,
                        color: AppSetting.primaryColor,
                      ),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppSetting.primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppSetting.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onStoreLogin(
                      viewModel,
                      usernameController.text,
                      passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null // ← disabled saat loading
                          : () => _onStoreLogin(
                                viewModel,
                                usernameController.text,
                                passwordController.text,
                              ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: state.isLoading
                            ? Colors.grey
                            : AppSetting.primaryColor,
                        foregroundColor: state.isLoading
                            ? Colors.white // teks tetap putih
                            : null,
                      ),
                      child: state.isLoading
                          ? const Text('Memuat...',
                              style: TextStyle(fontSize: 18))
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.push('/app/1/mode');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Masuk sebagai Pembeli',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
