import 'package:core/core.dart';
import 'package:dashboard/presentation/component/quirk_menu_button.dart';

class QuickMenu extends StatelessWidget {
  const QuickMenu({super.key});

  final bool isComingSoon = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> menuList = [
      QuickMenuButton(
        icon: Icons.description_outlined,
        label: 'Laporan',
        iconColor: AppColors.sbBlue,
        bgColor: AppColors.sbBg,
        onTap: () {
          if (isComingSoon) {
            context.pushNamed(AppRoutes.comingSoonScreen);
            return;
          } else {
            context.pushNamed(AppRoutes.report);
          }
        },
      ),
      QuickMenuButton(
        icon: Icons.inventory_2_outlined,
        label: 'Stok',
        iconColor: AppColors.sbOrange,
        bgColor: AppColors.sbBg,
        onTap: () {
          if (isComingSoon) {
            context.pushNamed(AppRoutes.comingSoonScreen);
            return;
          } else {
            context.pushNamed(AppRoutes.inventory);
          }
        },
      ),
      QuickMenuButton(
        icon: Icons.fastfood_outlined,
        label: 'Menu',
        iconColor: AppColors.sbGreen,
        bgColor: AppColors.sbBg,
        onTap: () {
          if (isComingSoon) {
            context.pushNamed(AppRoutes.comingSoonScreen);
            return;
          } else {
            context.pushNamed(AppRoutes.productManagement);
          }
        },
      ),
      QuickMenuButton(
        icon: Icons.settings_outlined,
        label: 'Pengaturan',
        iconColor: AppColors.sbGray,
        bgColor: AppColors.sbBg,
        onTap: () {
          if (isComingSoon) {
            context.pushNamed(AppRoutes.comingSoonScreen);
            return;
          } else {
            context.pushNamed(AppRoutes.settings);
          }
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Cepat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.sbBlueGray,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: menuList,
          ),
        ],
      ),
    );
  }
}
