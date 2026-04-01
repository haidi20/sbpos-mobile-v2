import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notification/presentation/screens/notification_screen.dart';
import 'package:product/presentation/screens/inventory_screen.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/help_screen.dart';
import 'package:setting/presentation/screens/notification_setting_screen.dart';
import 'package:setting/presentation/screens/payment_screen.dart';
import 'package:setting/presentation/screens/printer_screen.dart';
import 'package:setting/presentation/screens/profile_screen.dart';
import 'package:setting/presentation/screens/security_screen.dart';
import 'package:setting/presentation/screens/setting_screen.dart';
import 'package:setting/presentation/screens/store_screen.dart';
import '../../test_helpers.dart';

void main() {
  testWidgets('SettingsScreen menampilkan judul dan versi aplikasi',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
    );

    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('SBPOS App v2.1.0'), findsOneWidget);
  });

  testWidgets('SettingsScreen menampilkan data profil awal', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
    );

    expect(find.text('Sinta Dewi'), findsOneWidget);
    expect(find.text('Kasir - Shift Pagi'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
  });

  testWidgets('SettingsScreen menampilkan semua header section', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
    );

    expect(find.text('TOKO & PERANGKAT'), findsOneWidget);
    expect(find.text('AKUN & KEAMANAN'), findsOneWidget);
    expect(find.text('LAINNYA'), findsOneWidget);
  });

  testWidgets('SettingsScreen menampilkan summary store dari provider',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      arrange: (container) {
        final vm = container.read(settingViewModelProvider.notifier);
        vm.setStoreName('SB Coffee Samarinda');
        vm.setStoreBranch('Samarinda Ulu');
      },
    );

    expect(find.text('SB Coffee Samarinda - Samarinda Ulu'), findsOneWidget);
  });

  testWidgets('SettingsScreen menampilkan summary printer dari provider',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      arrange: (container) {
        final vm = container.read(settingViewModelProvider.notifier);
        vm.setPrinterConnected('Epson TM-T82', false);
      },
    );

    expect(find.text('Belum ada printer terhubung'), findsOneWidget);
  });

  testWidgets('SettingsScreen menampilkan summary payment dari provider',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      arrange: (container) {
        final vm = container.read(settingViewModelProvider.notifier);
        vm.setPaymentMethodActive(5, true);
      },
    );

    expect(
      find.text('Tunai (Cash), QRIS, Kartu Debit, Transfer Bank'),
      findsOneWidget,
    );
  });

  testWidgets('tap Informasi Toko menavigasi ke StoreScreen', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      extraRoutes: {
        AppRoutes.store: const StoreScreen(),
      },
    );

    await tester.tap(find.byKey(const Key('settings-store-item')));
    await tester.pumpAndSettle();

    expect(find.text('Informasi Toko'), findsWidgets);
  });

  testWidgets('tap Printer & Struk menavigasi ke PrinterScreen', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      extraRoutes: {
        AppRoutes.printer: const PrinterScreen(),
      },
    );

    await tester.tap(find.byKey(const Key('settings-printer-item')));
    await tester.pumpAndSettle();

    expect(find.text('Printer & Struk'), findsWidgets);
  });

  testWidgets('tap Metode Pembayaran menavigasi ke PaymentScreen',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      extraRoutes: {
        AppRoutes.payment: const PaymentScreen(),
      },
    );

    await tester.tap(find.byKey(const Key('settings-payment-item')));
    await tester.pumpAndSettle();

    expect(find.text('Metode Pembayaran'), findsWidgets);
  });

  testWidgets('tap Bantuan Pengguna menavigasi ke HelpScreen', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      extraRoutes: {
        AppRoutes.help: const HelpScreen(),
      },
    );

    await tester.ensureVisible(find.byKey(const Key('settings-help-item')));
    await tester.tap(find.byKey(const Key('settings-help-item')));
    await tester.pumpAndSettle();

    expect(find.text('Bantuan Pengguna'), findsWidgets);
  });

  testWidgets('tap Logout menampilkan dialog konfirmasi', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      extraRoutes: {
        AppRoutes.login: const Scaffold(body: Text('Login Screen')),
      },
    );

    await tester.ensureVisible(find.byKey(const Key('settings-logout-item')));
    await tester.tap(find.byKey(const Key('settings-logout-item')));
    await tester.pumpAndSettle();

    expect(find.text('Keluar Aplikasi'), findsWidgets);
    expect(
      find.text('Apakah Anda yakin ingin keluar dari aplikasi?'),
      findsOneWidget,
    );
  });

  testWidgets('pilih Tidak pada logout menutup dialog', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      extraRoutes: {
        AppRoutes.login: const Scaffold(body: Text('Login Screen')),
      },
    );

    await tester.ensureVisible(find.byKey(const Key('settings-logout-item')));
    await tester.tap(find.byKey(const Key('settings-logout-item')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tidak'));
    await tester.pumpAndSettle();

    expect(
      find.text('Apakah Anda yakin ingin keluar dari aplikasi?'),
      findsNothing,
    );
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('pilih Ya pada logout menavigasi ke login', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.settings,
      screen: const SettingsScreen(),
      extraRoutes: {
        AppRoutes.login: const Scaffold(body: Text('Login Screen')),
        AppRoutes.notification: const NotificationScreen(),
        AppRoutes.inventory: const InventoryScreen(),
        AppRoutes.profile: const ProfileScreen(),
        AppRoutes.notificationSetting: const NotificationSettingScreen(),
        AppRoutes.security: const SecurityScreen(),
      },
    );

    await tester.ensureVisible(find.byKey(const Key('settings-logout-item')));
    await tester.tap(find.byKey(const Key('settings-logout-item')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya'));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}
