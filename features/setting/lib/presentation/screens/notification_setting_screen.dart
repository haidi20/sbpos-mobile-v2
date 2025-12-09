import 'package:core/core.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool pushNotif = true;
  bool sound = true;
  bool stockAlert = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildTile(
                  Icons.notifications,
                  Colors.blue,
                  'Push Notifikasi',
                  pushNotif,
                  (v) => setState(
                    () => pushNotif = v,
                  ),
                ),
                const Divider(height: 1),
                _buildTile(
                  Icons.volume_up,
                  Colors.orange,
                  'Suara Transaksi',
                  sound,
                  (v) => setState(
                    () => sound = v,
                  ),
                ),
                const Divider(height: 1),
                _buildTile(
                  Icons.lock_clock,
                  Colors.red,
                  'Alert Stok Menipis',
                  stockAlert,
                  (v) => setState(
                    () => stockAlert = v,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, Color color, String title, bool value,
      Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                8,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      activeColor: AppColors.sbBlue,
    );
  }
}
