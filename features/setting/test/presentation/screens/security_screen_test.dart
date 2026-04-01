import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/security_screen.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('SecurityScreen menampilkan judul dan tombol update',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    expect(find.text('Keamanan'), findsWidgets);
    expect(find.text('Update Keamanan'), findsOneWidget);
  });

  testWidgets('SecurityScreen menampilkan warning keamanan', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    expect(
      find.textContaining('Untuk keamanan, ganti PIN atau Password Anda'),
      findsOneWidget,
    );
  });

  testWidgets('semua field PIN bersifat obscureText', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    final fields = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.length, 3);
    expect(fields.every((field) => field.obscureText), isTrue);
  });

  testWidgets('input PIN lama mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '111111');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).security.oldPin,
      equals('111111'),
    );
  });

  testWidgets('input PIN baru mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(1), '222222');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).security.newPin,
      equals('222222'),
    );
  });

  testWidgets('input konfirmasi PIN mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(2), '333333');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).security.confirmPin,
      equals('333333'),
    );
  });

  testWidgets('update keamanan valid mengosongkan form dan kembali ke root',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
      pushFromRoot: true,
    );

    await tester.enterText(find.byType(TextFormField).at(0), '111111');
    await tester.enterText(find.byType(TextFormField).at(1), '222222');
    await tester.enterText(find.byType(TextFormField).at(2), '222222');
    await tester.ensureVisible(find.byKey(const Key('security-save-button')));
    await tester.tap(find.byKey(const Key('security-save-button')));
    await tester.pumpAndSettle();

    final securityState = container.read(settingViewModelProvider).security;
    expect(securityState.oldPin, isEmpty);
    expect(securityState.newPin, isEmpty);
    expect(securityState.confirmPin, isEmpty);
    expect(
      securityState.successMessage,
      equals('Pengaturan keamanan berhasil diperbarui'),
    );
    expect(find.text(kSettingTestRootText), findsOneWidget);
  });

  testWidgets('update dengan field kosong menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    await tester.ensureVisible(find.byKey(const Key('security-save-button')));
    await tester.tap(find.byKey(const Key('security-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).security.errorMessage,
      equals('Semua field PIN wajib diisi'),
    );
    expect(find.text('Semua field PIN wajib diisi'), findsOneWidget);
  });

  testWidgets('update dengan panjang PIN kurang dari 6 digit menampilkan error',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '11111');
    await tester.enterText(find.byType(TextFormField).at(1), '22222');
    await tester.enterText(find.byType(TextFormField).at(2), '22222');
    await tester.ensureVisible(find.byKey(const Key('security-save-button')));
    await tester.tap(find.byKey(const Key('security-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).security.errorMessage,
      equals('PIN harus terdiri dari 6 digit angka'),
    );
  });

  testWidgets('update dengan PIN non digit menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'abcdef');
    await tester.enterText(find.byType(TextFormField).at(1), '12345a');
    await tester.enterText(find.byType(TextFormField).at(2), '12345a');
    await tester.ensureVisible(find.byKey(const Key('security-save-button')));
    await tester.tap(find.byKey(const Key('security-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).security.errorMessage,
      equals('PIN harus terdiri dari 6 digit angka'),
    );
  });

  testWidgets('update dengan konfirmasi berbeda menampilkan error',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '111111');
    await tester.enterText(find.byType(TextFormField).at(1), '222222');
    await tester.enterText(find.byType(TextFormField).at(2), '333333');
    await tester.ensureVisible(find.byKey(const Key('security-save-button')));
    await tester.tap(find.byKey(const Key('security-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).security.errorMessage,
      equals('PIN baru dan konfirmasi PIN harus sama'),
    );
    expect(
      find.text('PIN baru dan konfirmasi PIN harus sama'),
      findsOneWidget,
    );
  });

  testWidgets('tap tombol back kembali ke root route', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.security,
      screen: const SecurityScreen(),
      pushFromRoot: true,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text(kSettingTestRootText), findsOneWidget);
  });
}
