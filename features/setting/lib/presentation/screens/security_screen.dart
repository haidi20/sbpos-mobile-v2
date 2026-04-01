import 'package:core/core.dart';
import 'package:setting/presentation/providers/setting.provider.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  static const String _textWarning =
      'Untuk keamanan, ganti PIN atau Password Anda secara berkala. Jangan berikan kode akses kepada siapapun.';

  late final TextEditingController _oldPinController;
  late final TextEditingController _newPinController;
  late final TextEditingController _confirmPinController;

  @override
  void initState() {
    super.initState();
    final securityState = ref.read(settingSecurityStateProvider);
    _oldPinController = TextEditingController(text: securityState.oldPin);
    _newPinController = TextEditingController(text: securityState.newPin);
    _confirmPinController =
        TextEditingController(text: securityState.confirmPin);
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(settingViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Keamanan',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
        shadowColor: Colors.grey.shade50,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _textWarning,
                style: TextStyle(
                  height: 1.5,
                  fontSize: 12,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              'PIN Lama',
              _oldPinController,
              onChanged: viewModel.setSecurityOldPin,
            ),
            _buildPasswordField(
              'PIN Baru',
              _newPinController,
              onChanged: viewModel.setSecurityNewPin,
            ),
            _buildPasswordField(
              'Konfirmasi PIN Baru',
              _confirmPinController,
              onChanged: viewModel.setSecurityConfirmPin,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('security-save-button'),
                onPressed: () async {
                  final ok = await viewModel.onUpdateSecurity();
                  final latestSecurity = ref.read(settingSecurityStateProvider);

                  if (!context.mounted) {
                    return;
                  }

                  if (ok) {
                    _oldPinController.clear();
                    _newPinController.clear();
                    _confirmPinController.clear();
                    showSuccessSnackBar(context, latestSecurity.successMessage);
                    context.pop();
                  } else {
                    showErrorSnackBar(context, latestSecurity.errorMessage);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sbBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Keamanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: '******',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.sbBlue.withOpacity(0.2),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
