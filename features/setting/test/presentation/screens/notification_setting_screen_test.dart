import 'package:flutter_test/flutter_test.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/notification_setting_screen.dart';
import '../../test_helpers.dart';

void main() {
  testWidgets('NotificationSettingScreen menampilkan judul', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    expect(find.text('Notifikasi'), findsWidgets);
  });

  testWidgets('menampilkan tile Push Notifikasi', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    expect(find.text('Push Notifikasi'), findsOneWidget);
  });

  testWidgets('menampilkan tile Suara Transaksi', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    expect(find.text('Suara Transaksi'), findsOneWidget);
  });

  testWidgets('menampilkan tile Alert Stok Menipis', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    expect(find.text('Alert Stok Menipis'), findsOneWidget);
  });

  testWidgets('state awal push notification aktif', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    expect(
      container.read(settingViewModelProvider).notification.pushNotification,
      isTrue,
    );
  });

  testWidgets('state awal suara transaksi aktif', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    expect(
      container.read(settingViewModelProvider).notification.transactionSound,
      isTrue,
    );
  });

  testWidgets('state awal alert stok aktif', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    expect(
      container.read(settingViewModelProvider).notification.stockAlert,
      isTrue,
    );
  });

  testWidgets('toggle Push Notifikasi mengubah state', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    await tester.tap(find.text('Push Notifikasi'));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).notification.pushNotification,
      isFalse,
    );
  });

  testWidgets('toggle Suara Transaksi mengubah state', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    await tester.tap(find.text('Suara Transaksi'));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).notification.transactionSound,
      isFalse,
    );
  });

  testWidgets('toggle Alert Stok Menipis mengubah state', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    await tester.tap(find.text('Alert Stok Menipis'));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).notification.stockAlert,
      isFalse,
    );
  });

  testWidgets('toggle Push Notifikasi dua kali mengembalikan state awal',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    await tester.tap(find.text('Push Notifikasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push Notifikasi'));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).notification.pushNotification,
      isTrue,
    );
  });

  testWidgets('toggle semua switch ke off mengubah seluruh state', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/notification-setting',
      screen: const NotificationSettingScreen(),
    );

    await tester.tap(find.text('Push Notifikasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suara Transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alert Stok Menipis'));
    await tester.pumpAndSettle();

    final state = container.read(settingViewModelProvider).notification;
    expect(state.pushNotification, isFalse);
    expect(state.transactionSound, isFalse);
    expect(state.stockAlert, isFalse);
  });
}
