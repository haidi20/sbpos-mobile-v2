import 'package:core/core.dart';
import 'package:setting/presentation/providers/setting.provider.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  late final TextEditingController _storeNameController;
  late final TextEditingController _branchController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final storeState = ref.read(settingStoreStateProvider);
    _storeNameController = TextEditingController(text: storeState.storeName);
    _branchController = TextEditingController(text: storeState.branch);
    _addressController = TextEditingController(text: storeState.address);
    _phoneController = TextEditingController(text: storeState.phone);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _branchController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(settingViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Informasi Toko',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Aksi: Pop halaman saat ini dari tumpukan
                  context.pop();
                },
              )
            : null, // Jika tidak ada history, tombol leading tidak muncul
        shadowColor: Colors.grey.shade50,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo Upload
            Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      style: BorderStyle.solid,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Icon(
                    size: 32,
                    Icons.store_outlined,
                    color: Colors.grey.shade400,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    //
                  },
                  child: const Text(
                    'Ubah Logo',
                    style: TextStyle(
                      color: AppColors.sbBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Forms
            _buildTextField(
              'Nama Toko',
              _storeNameController,
              onChanged: viewModel.setStoreName,
            ),
            _buildTextField(
              'Cabang',
              _branchController,
              onChanged: viewModel.setStoreBranch,
            ),
            _buildTextField(
              'Alamat Lengkap',
              _addressController,
              maxLines: 3,
              onChanged: viewModel.setStoreAddress,
            ),
            _buildTextField(
              'Nomor Telepon',
              _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: viewModel.setStorePhone,
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('store-save-button'),
                onPressed: () async {
                  final ok = await viewModel.onSaveStoreInfo();
                  final latestStore = ref.read(settingStoreStateProvider);

                  if (!context.mounted) {
                    return;
                  }

                  if (ok) {
                    showSuccessSnackBar(context, latestStore.successMessage);
                    context.pop();
                  } else {
                    showErrorSnackBar(context, latestStore.errorMessage);
                  }
                },
                icon: const Icon(
                  size: 18,
                  Icons.save,
                ),
                label: const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sbBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
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
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
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
