import 'package:core/core.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  final String textWarning =
      'Untuk keamanan, ganti PIN atau Password Anda secara berkala. Jangan berikan kode akses kepada siapapun.';

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  // Aksi: Pop halaman saat ini dari tumpukan
                  context.pop();
                },
              )
            : null, // Jika tidak ada history, tombol leading tidak muncul
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
                textWarning,
                style: TextStyle(
                  height: 1.5,
                  fontSize: 12,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildPasswordField('PIN Lama'),
            _buildPasswordField('PIN Baru'),
            _buildPasswordField('Konfirmasi PIN Baru'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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

  Widget _buildPasswordField(String label) {
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
            obscureText: true,
            decoration: InputDecoration(
              hintText: '******',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
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
