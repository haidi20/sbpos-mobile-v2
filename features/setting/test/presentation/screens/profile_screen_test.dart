import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/profile_screen.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('ProfileScreen menampilkan judul dan tombol simpan',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    expect(find.text('Edit Profil'), findsWidgets);
    expect(find.text('Simpan Profil'), findsOneWidget);
  });

  testWidgets('ProfileScreen menampilkan nilai awal form', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('EMP-2023-001'), findsOneWidget);
    expect(find.text('budi@sbpos.com'), findsOneWidget);
    expect(find.text('0812-9999-8888'), findsOneWidget);
  });

  testWidgets('field ID Karyawan bersifat disabled', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    final employeeIdField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );
    expect(employeeIdField.enabled, isFalse);
  });

  testWidgets('input nama mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Sinta Dewi');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).profile.name,
      equals('Sinta Dewi'),
    );
  });

  testWidgets('input email mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    await tester.enterText(
      find.byType(TextFormField).at(2),
      'sinta@sbpos.com',
    );
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).profile.email,
      equals('sinta@sbpos.com'),
    );
  });

  testWidgets('input phone mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(3), '081311112222');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).profile.phone,
      equals('081311112222'),
    );
  });

  testWidgets('save profil valid memunculkan snackbar sukses',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Sinta Dewi');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'sinta@sbpos.com',
    );
    await tester.enterText(find.byType(TextFormField).at(3), '081311112222');
    await tester.ensureVisible(find.byKey(const Key('profile-save-button')));
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).profile.successMessage,
      equals('Profil berhasil diperbarui'),
    );
    expect(
      container.read(settingViewModelProvider).profileCard.name,
      equals('Sinta Dewi'),
    );
    expect(find.text('Profil berhasil diperbarui'), findsOneWidget);
  });

  testWidgets('save dengan nama kosong menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.ensureVisible(find.byKey(const Key('profile-save-button')));
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).profile.errorMessage,
      equals('Nama, email, dan nomor handphone wajib diisi'),
    );
  });

  testWidgets('save dengan email kosong menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(2), '');
    await tester.ensureVisible(find.byKey(const Key('profile-save-button')));
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).profile.errorMessage,
      equals('Nama, email, dan nomor handphone wajib diisi'),
    );
  });

  testWidgets('save dengan phone kosong menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(3), '');
    await tester.ensureVisible(find.byKey(const Key('profile-save-button')));
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).profile.errorMessage,
      equals('Nama, email, dan nomor handphone wajib diisi'),
    );
  });

  testWidgets('save dengan format email salah menampilkan error',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(2), 'email-salah');
    await tester.ensureVisible(find.byKey(const Key('profile-save-button')));
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).profile.errorMessage,
      equals('Format email tidak valid'),
    );
    expect(find.text('Format email tidak valid'), findsOneWidget);
  });

  testWidgets('tap tombol back kembali ke root route', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.profile,
      screen: const ProfileScreen(),
      pushFromRoot: true,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text(kSettingTestRootText), findsOneWidget);
  });
}
