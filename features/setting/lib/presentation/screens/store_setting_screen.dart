import 'package:core/core.dart';

class StoreSettingsPage extends StatelessWidget {
  const StoreSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Informasi Toko',
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
                        color: Colors.grey.shade300,
                        style: BorderStyle
                            .solid), // Dashed border perlu package lain, pakai solid dulu
                  ),
                  child: Icon(Icons.store_outlined,
                      size: 32, color: Colors.grey.shade400),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ubah Logo',
                      style: TextStyle(
                          color: AppColors.sbBlue,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Forms
            _buildTextField('Nama Toko', 'SB Coffee'),
            _buildTextField('Cabang', 'Jakarta Selatan'),
            _buildTextField(
                'Alamat Lengkap', 'Jl. Sudirman No. 45, SCBD, Jakarta Selatan',
                maxLines: 3),
            _buildTextField('Nomor Telepon', '0812-3456-7890',
                keyboardType: TextInputType.phone),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sbBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: initialValue,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.sbBlue.withOpacity(0.2), width: 2)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
