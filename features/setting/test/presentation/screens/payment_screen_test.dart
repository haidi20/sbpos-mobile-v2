import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/payment_screen.dart';
import 'package:setting/testing/test_helpers.dart';

void main() {
  testWidgets('PaymentScreen menampilkan judul', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    expect(find.text('Metode Pembayaran'), findsWidgets);
  });

  testWidgets('PaymentScreen menampilkan Tunai (Cash)', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    expect(find.text('Tunai (Cash)'), findsOneWidget);
  });

  testWidgets('PaymentScreen menampilkan QRIS', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    expect(find.text('QRIS'), findsOneWidget);
  });

  testWidgets('PaymentScreen menampilkan Kartu Debit', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    expect(find.text('Kartu Debit'), findsOneWidget);
  });

  testWidgets('PaymentScreen menampilkan Kartu Kredit', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    expect(find.text('Kartu Kredit'), findsOneWidget);
  });

  testWidgets('PaymentScreen menampilkan Transfer Bank', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    expect(find.text('Transfer Bank'), findsOneWidget);
  });

  testWidgets('tap Transfer Bank mengaktifkan metode', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    await tester.tap(find.byKey(const Key('payment-method-5')));
    await tester.pumpAndSettle();

    expect(
      container
          .read(settingViewModelProvider)
          .payment
          .methods
          .firstWhere((method) => method.id == 5)
          .isActive,
      isTrue,
    );
  });

  testWidgets('tap QRIS menonaktifkan metode', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    await tester.tap(find.byKey(const Key('payment-method-2')));
    await tester.pumpAndSettle();

    expect(
      container
          .read(settingViewModelProvider)
          .payment
          .methods
          .firstWhere((method) => method.id == 2)
          .isActive,
      isFalse,
    );
  });

  testWidgets('tap metode yang sama dua kali mengembalikan state awal',
      (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    await tester.tap(find.byKey(const Key('payment-method-5')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-method-5')));
    await tester.pumpAndSettle();

    expect(
      container
          .read(settingViewModelProvider)
          .payment
          .methods
          .firstWhere((method) => method.id == 5)
          .isActive,
      isFalse,
    );
  });

  testWidgets('style item berubah saat metode diaktifkan', (tester) async {
    await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    final boxBefore =
        findAnimatedContainerDecoration(tester, find.text('Transfer Bank'));
    expect(boxBefore.color, equals(Colors.white));

    await tester.tap(find.byKey(const Key('payment-method-5')));
    await tester.pumpAndSettle();

    final boxAfter =
        findAnimatedContainerDecoration(tester, find.text('Transfer Bank'));
    expect(boxAfter.color, equals(Colors.blue.shade50));
  });

  testWidgets('beberapa metode bisa aktif bersamaan', (tester) async {
    final container = await pumpSettingRoute(
      tester,
      routePath: '/payment',
      screen: const PaymentScreen(),
    );

    await tester.tap(find.byKey(const Key('payment-method-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-method-5')));
    await tester.pumpAndSettle();

    final methods = container.read(settingViewModelProvider).payment.methods;
    expect(methods.firstWhere((method) => method.id == 4).isActive, isTrue);
    expect(methods.firstWhere((method) => method.id == 5).isActive, isTrue);
  });
}
