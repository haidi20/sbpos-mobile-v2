import 'package:core/core.dart';
import 'package:setting/presentation/component/setting_item.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/view_models/setting.state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileCard = ref.watch(settingProfileCardStateProvider);
    final storeSummary = ref.watch(settingStoreSummaryProvider);
    final printerSummary = ref.watch(settingPrinterSummaryProvider);
    final paymentSummary = ref.watch(settingPaymentSummaryProvider);
    final notificationSummary = ref.watch(settingNotificationSummaryProvider);
    final versionLabel = ref.watch(settingVersionLabelProvider);

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
                  if (context.canPop())
                    IconButton(
                      key: const Key('settings-back-button'),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pengaturan',
                    key: Key('settings-title'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // --- Profile Card ---
              _buildProfileCard(profileCard),
              const SizedBox(height: 24),
              // --- Group: Toko & Perangkat ---
              _buildSectionHeader('Toko & Perangkat'),
              _buildGroupContainer([
                SettingItem(
                  key: const Key('settings-store-item'),
                  icon: Icons.store_outlined,
                  label: 'Informasi Toko',
                  subLabel: storeSummary,
                  iconColor: AppColors.sbBlue,
                  onTap: () => context.push(AppRoutes.store),
                ),
                const Divider(height: 1),
                SettingItem(
                  key: const Key('settings-printer-item'),
                  icon: Icons.print_outlined,
                  label: 'Printer & Struk',
                  subLabel: printerSummary,
                  iconColor: AppColors.sbOrange,
                  onTap: () => context.push(AppRoutes.printer),
                ),
                const Divider(height: 1),
                SettingItem(
                  key: const Key('settings-payment-item'),
                  icon: Icons.credit_card_outlined,
                  label: 'Metode Pembayaran',
                  subLabel: paymentSummary,
                  iconColor: Colors.purple,
                  onTap: () => context.push(AppRoutes.payment),
                ),
              ]),
              const SizedBox(height: 24),
              // --- Group: Akun ---
              _buildSectionHeader('Akun & Keamanan'),
              _buildGroupContainer([
                SettingItem(
                  key: const Key('settings-profile-item'),
                  icon: Icons.person_outline,
                  label: 'Ubah Profil',
                  onTap: () => context.push(AppRoutes.profile),
                ),
                const Divider(height: 1),
                SettingItem(
                  key: const Key('settings-notification-item'),
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  subLabel: notificationSummary,
                  onTap: () => context.push(AppRoutes.notificationSetting),
                ),
                const Divider(height: 1),
                SettingItem(
                  key: const Key('settings-security-item'),
                  icon: Icons.lock_outline,
                  label: 'Ubah PIN / Password',
                  onTap: () => context.push(AppRoutes.security),
                ),
              ]),

              const SizedBox(height: 24),

              // --- Group: Lainnya ---
              _buildSectionHeader('Lainnya'),
              _buildGroupContainer(
                [
                  SettingItem(
                    key: const Key('settings-help-item'),
                    icon: Icons.help_outline,
                    label: 'Bantuan Pengguna',
                    onTap: () => context.push(AppRoutes.help),
                  ),
                  const Divider(height: 1),
                  InkWell(
                    key: const Key('settings-logout-item'),
                    onTap: () => _showLogoutConfirmation(context),
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
                            child: Icon(
                              Icons.logout,
                              size: 20,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Keluar Aplikasi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Text(
                versionLabel,
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

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar Aplikasi'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  Widget _buildProfileCard(SettingProfileCardState profileCard) {
    return Container(
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
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              image: DecorationImage(
                image: NetworkImage(profileCard.avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileCard.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profileCard.role,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Text(
                    profileCard.statusLabel,
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        key: Key('settings-section-$title'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
        ),
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
