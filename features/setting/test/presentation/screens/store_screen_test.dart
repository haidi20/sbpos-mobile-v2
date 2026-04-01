import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/store_screen.dart';
import '../../test_helpers.dart';

void main() {
  testWidgets('StoreScreen menampilkan judul dan tombol simpan', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    expect(find.text('Informasi Toko'), findsWidgets);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });

  testWidgets('StoreScreen menampilkan nilai awal form', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    expect(find.text('SB Coffee'), findsOneWidget);
    expect(find.text('Jakarta Selatan'), findsOneWidget);
    expect(find.text('0812-3456-7890'), findsOneWidget);
  });

  testWidgets('StoreScreen menampilkan tombol ubah logo', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    expect(find.text('Ubah Logo'), findsOneWidget);
  });

  testWidgets('input nama toko mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'SB Coffee Baru');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).store.storeName,
      equals('SB Coffee Baru'),
    );
  });

  testWidgets('input cabang mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(1), 'Balikpapan');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).store.branch,
      equals('Balikpapan'),
    );
  });

  testWidgets('input alamat mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(2), 'Jl. Baru No. 1');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).store.address,
      equals('Jl. Baru No. 1'),
    );
  });

  testWidgets('input phone mengubah state provider', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(3), '081299998888');
    await tester.pump();

    expect(
      container.read(settingViewModelProvider).store.phone,
      equals('081299998888'),
    );
  });

  testWidgets('save valid store info memunculkan state sukses dan pop',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
      pushFromRoot: true,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'SB Coffee Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'Samarinda');
    await tester.enterText(find.byType(TextFormField).at(2), 'Jl. Kenangan');
    await tester.enterText(find.byType(TextFormField).at(3), '081234567890');
    await tester.ensureVisible(find.byKey(const Key('store-save-button')));
    await tester.tap(find.byKey(const Key('store-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).store.successMessage,
      equals('Informasi toko berhasil diperbarui'),
    );
    expect(find.text(kSettingTestRootText), findsOneWidget);
  });

  testWidgets('save dengan nama toko kosong menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.ensureVisible(find.byKey(const Key('store-save-button')));
    await tester.tap(find.byKey(const Key('store-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).store.errorMessage,
      equals('Semua field informasi toko wajib diisi'),
    );
    expect(find.text('Semua field informasi toko wajib diisi'), findsOneWidget);
  });

  testWidgets('save dengan cabang kosong menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.ensureVisible(find.byKey(const Key('store-save-button')));
    await tester.tap(find.byKey(const Key('store-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).store.errorMessage,
      equals('Semua field informasi toko wajib diisi'),
    );
  });

  testWidgets('save dengan alamat kosong menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(2), '');
    await tester.ensureVisible(find.byKey(const Key('store-save-button')));
    await tester.tap(find.byKey(const Key('store-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).store.errorMessage,
      equals('Semua field informasi toko wajib diisi'),
    );
  });

  testWidgets('save dengan phone kosong menampilkan error', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.store,
      screen: const StoreScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(3), '');
    await tester.ensureVisible(find.byKey(const Key('store-save-button')));
    await tester.tap(find.byKey(const Key('store-save-button')));
    await tester.pumpAndSettle();

    expect(
      container.read(settingViewModelProvider).store.errorMessage,
      equals('Semua field informasi toko wajib diisi'),
    );
  });
}
