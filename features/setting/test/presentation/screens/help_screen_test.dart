import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/help_screen.dart';

import 'package:setting/testing/test_helpers.dart';

void main() {
  testWidgets('HelpScreen menampilkan judul halaman', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    expect(find.text('Bantuan Pengguna'), findsWidgets);
  });

  testWidgets('HelpScreen menampilkan banner bantuan', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    expect(find.text('Butuh Bantuan?'), findsOneWidget);
    expect(find.text('Tim support kami siap membantu 24/7'), findsOneWidget);
    expect(find.text('Chat WhatsApp'), findsOneWidget);
  });

  testWidgets('HelpScreen menampilkan label FAQ', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    expect(find.text('FAQ'), findsOneWidget);
  });

  testWidgets('state awal FAQ seluruhnya tertutup', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    final faqs = container.read(settingViewModelProvider).help.faqs;
    expect(faqs.every((item) => item.isExpanded == false), isTrue);
  });

  testWidgets('HelpScreen menampilkan semua pertanyaan FAQ', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    expect(find.text('Cara menghubungkan printer?'), findsOneWidget);
    expect(find.text('Bagaimana cara refund transaksi?'), findsOneWidget);
    expect(find.text('Lupa PIN akses?'), findsOneWidget);
    expect(find.text('Cara export laporan ke Excel?'), findsOneWidget);
  });

  testWidgets('tap Chat WhatsApp memunculkan snackbar warning',
      (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    await tester.tap(find.byKey(const Key('help-chat-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Chat support belum tersedia pada build ini'),
      findsOneWidget,
    );
  });

  testWidgets('expand FAQ pertama menampilkan jawaban dan update state',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    await tester.tap(find.byKey(const Key('help-faq-0')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Pastikan perangkat printer sudah aktif'),
      findsOneWidget,
    );
    expect(container.read(settingViewModelProvider).help.faqs[0].isExpanded, isTrue);
  });

  testWidgets('expand FAQ kedua menutup FAQ pertama', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    await tester.tap(find.byKey(const Key('help-faq-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('help-faq-1')));
    await tester.pumpAndSettle();

    final faqs = container.read(settingViewModelProvider).help.faqs;
    expect(faqs[0].isExpanded, isFalse);
    expect(faqs[1].isExpanded, isTrue);
    expect(find.textContaining('alur refund belum tersedia'), findsOneWidget);
  });

  testWidgets('collapse FAQ yang sudah terbuka menyembunyikan jawaban',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    await tester.tap(find.byKey(const Key('help-faq-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('help-faq-1')));
    await tester.pumpAndSettle();

    expect(container.read(settingViewModelProvider).help.faqs[1].isExpanded, isFalse);
    expect(find.textContaining('alur refund belum tersedia'), findsNothing);
  });

  testWidgets('expand FAQ ketiga menampilkan jawaban yang sesuai',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    await tester.ensureVisible(find.byKey(const Key('help-faq-2')));
    await tester.tap(find.byKey(const Key('help-faq-2')));
    await tester.pumpAndSettle();

    expect(container.read(settingViewModelProvider).help.faqs[2].isExpanded, isTrue);
    expect(
      find.textContaining('Gunakan halaman Ubah PIN / Password'),
      findsOneWidget,
    );
  });

  testWidgets('expand FAQ keempat menutup FAQ ketiga', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
    );

    await tester.ensureVisible(find.byKey(const Key('help-faq-2')));
    await tester.tap(find.byKey(const Key('help-faq-2')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('help-faq-3')));
    await tester.tap(find.byKey(const Key('help-faq-3')));
    await tester.pumpAndSettle();

    final faqs = container.read(settingViewModelProvider).help.faqs;
    expect(faqs[2].isExpanded, isFalse);
    expect(faqs[3].isExpanded, isTrue);
    expect(
      find.textContaining('Fitur export laporan belum tersedia'),
      findsOneWidget,
    );
  });

  testWidgets('tap tombol back kembali ke root route', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: AppRoutes.help,
      screen: const HelpScreen(),
      pushFromRoot: true,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text(kSettingTestRootText), findsOneWidget);
  });
}
