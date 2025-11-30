import 'package:core/core.dart';
import 'package:setting/presentation/component/setting_item.dart';
import 'package:setting/presentation/screens/help_setting_screen.dart';
import 'package:setting/presentation/screens/store_setting_screen.dart';
import 'package:setting/presentation/screens/payment_setting_screen.dart';
import 'package:setting/presentation/screens/printer_setting_screen.dart';
import 'package:setting/presentation/screens/profile_setting_screen.dart';
import 'package:setting/presentation/screens/secutiry_setting_screen.dart';
import 'package:setting/presentation/screens/notification_setting_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // --- Profile Card ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage(
                              "https://picsum.photos/200/200?random=user"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Budi Santoso',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Kasir - Shift Pagi',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: Text(
                              'Online',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Group: Toko & Perangkat ---
              _buildSectionHeader('Toko & Perangkat'),
              _buildGroupContainer([
                SettingItem(
                  icon: Icons.store_outlined,
                  label: 'Informasi Toko',
                  subLabel: 'SB Coffee - Jakarta Selatan',
                  iconColor: AppColors.sbBlue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoreSettingsPage(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SettingItem(
                  icon: Icons.print_outlined,
                  label: 'Printer & Struk',
                  subLabel: 'Epson TM-T82 (Connected)',
                  iconColor: AppColors.sbOrange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrinterSettingsPage(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SettingItem(
                  icon: Icons.credit_card_outlined,
                  label: 'Metode Pembayaran',
                  subLabel: 'QRIS, Tunai, Kartu Debit',
                  iconColor: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentSettingsPage(),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              // --- Group: Akun ---
              _buildSectionHeader('Akun & Keamanan'),
              _buildGroupContainer([
                SettingItem(
                  icon: Icons.person_outline,
                  label: 'Edit Profil',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSettingsPage(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SettingItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  subLabel: 'Bunyi & Getar Aktif',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsPage(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SettingItem(
                  icon: Icons.lock_outline,
                  label: 'Ubah PIN / Password',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SecuritySettingsPage(),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              // --- Group: Lainnya ---
              _buildSectionHeader('Lainnya'),
              _buildGroupContainer([
                SettingItem(
                  icon: Icons.help_outline,
                  label: 'Bantuan & Support',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpSettingsPage(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                InkWell(
                  onTap: () {
                    // Logic Logout
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle),
                          child: Icon(Icons.logout,
                              size: 20, color: Colors.red.shade400),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text('Keluar Aplikasi',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red)),
                        ),
                        Icon(Icons.chevron_right,
                            size: 18, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 32),
              Text(
                'SB POS App v1.2.0 • Build 20231024',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildGroupContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }
}
