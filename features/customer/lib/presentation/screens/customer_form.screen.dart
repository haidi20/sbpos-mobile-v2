import 'package:core/core.dart';

class CustomerFormScreen extends StatelessWidget {
  const CustomerFormScreen({
    super.key,
    required this.viewModel,
  });

  // Gunakan dynamic agar tidak mengikat ke tipe tertentu
  final dynamic viewModel;

  static const Color _sbBlue = AppColors.sbLightBlue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildAddCustomerForm(context, viewModel, _sbBlue),
    );
  }

  // --------------------------------------------------------------------------
  // FROM SPEC: _buildAddCustomerForm + _buildNotesField
  Widget _buildAddCustomerForm(
      BuildContext context, dynamic viewModel, Color sbBlue) {
    // Implementasi Form Pelanggan Baru
    return Column(
      children: [
        const SizedBox(height: 16),
        DottedBorder(
          color: sbBlue,
          strokeWidth: 2,
          dashPattern: const [6, 3],
          borderType: BorderType.Circle,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[50],
            ),
            child: const Icon(
              LucideIcons.userPlus,
              size: 32,
              color: _sbBlue,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildInputField(
          label: 'Nama Pelanggan *',
          icon: LucideIcons.user,
          placeholder: 'Nama lengkap',
          value: (viewModel?.draftCustomer?.name ?? '').toString(),
          onChanged: (v) => viewModel?.updateDraft?.call('name', v),
        ),
        _buildInputField(
          label: 'Nomor Telepon *',
          icon: LucideIcons.phone,
          placeholder: '08xxxxxxxx',
          value: (viewModel?.draftCustomer?.phone ?? '').toString(),
          onChanged: (v) => viewModel?.updateDraft?.call('phone', v),
          keyboardType: TextInputType.phone,
        ),
        _buildInputField(
          label: 'Email (Opsional)',
          icon: LucideIcons.mail,
          placeholder: 'email@example.com',
          value: (viewModel?.draftCustomer?.email ?? '').toString(),
          onChanged: (v) => viewModel?.updateDraft?.call('email', v),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 8),
        _buildNotesField(
          label: 'Catatan Khusus',
          placeholder: 'Contoh: Alergi kacang...',
          value: (viewModel?.draftCustomer?.note ?? '').toString(),
          onChanged: (v) => viewModel?.updateDraft?.call('note', v),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await viewModel?.handleSaveNewCustomer?.call();
              // Tutup sheet setelah simpan, pastikan widget masih mounted
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(LucideIcons.save, size: 18, color: Colors.white),
            label: const Text(
              'Simpan & Pilih Pelanggan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: sbBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              elevation: 5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField({
    required String label,
    required String placeholder,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: 4,
          minLines: 3,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                width: 1.5,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Helper yang dipakai oleh _buildAddCustomerForm
  Widget _buildInputField({
    required String label,
    required IconData icon,
    required String placeholder,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  width: 1.5,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
