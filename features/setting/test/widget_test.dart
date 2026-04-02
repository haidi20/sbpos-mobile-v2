import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/screens/payment_screen.dart';

import 'package:setting/testing/setting_test_fixtures.dart';

void main() {
  testWidgets('PaymentScreen menampilkan metode pembayaran dan toggle state',
      (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/payment',
      routes: [
        GoRoute(
          path: '/payment',
          builder: (context, state) => const PaymentScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingRemoteDataSourceProvider.overrideWithValue(
            FakeSettingRemoteDataSource(),
          ),
          settingLocalDataSourceProvider.overrideWithValue(
            FakeSettingLocalDataSource(),
          ),
        printerFacadeProvider.overrideWithValue(
          FakePrinterFacade(),
        ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    expect(find.text('Tunai (Cash)'), findsOneWidget);
    expect(find.text('Transfer Bank'), findsOneWidget);

    final containerBefore = tester.widget<AnimatedContainer>(
      find.ancestor(
        of: find.text('Transfer Bank'),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final boxBefore = containerBefore.decoration! as BoxDecoration;
    expect(boxBefore.color, equals(Colors.white));

    await tester.tap(find.byKey(const Key('payment-method-5')));
    await tester.pumpAndSettle();

    final containerAfter = tester.widget<AnimatedContainer>(
      find.ancestor(
        of: find.text('Transfer Bank'),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final boxAfter = containerAfter.decoration! as BoxDecoration;
    expect(boxAfter.color, equals(Colors.blue.shade50));
  });
}
