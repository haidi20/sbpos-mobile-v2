import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';
import 'package:transaction/presentation/providers/open_cashier.provider.dart';
import 'package:transaction/presentation/screens/open_cashier.screen.dart';

class _FakeShiftRepository implements ShiftRepository {
  _FakeShiftRepository({
    this.lastOpeningBalance,
  });

  final int? lastOpeningBalance;

  @override
  Future<Either<Failure, ShiftStatusEntity>> getShiftStatus() async {
    return Right(
      ShiftStatusEntity(
        isOpen: false,
        message: 'Shift belum dibuka',
        shift: lastOpeningBalance == null
            ? null
            : ShiftEntity(
                idServer: 77,
                shiftNumber: 1,
                openingBalance: lastOpeningBalance,
                isClosed: true,
              ),
      ),
    );
  }

  @override
  Future<Either<Failure, ShiftEntity?>> getLatestShift() async {
    if (lastOpeningBalance == null) {
      return const Right(null);
    }
    return Right(
      ShiftEntity(
        openingBalance: lastOpeningBalance,
        shiftNumber: 1,
      ),
    );
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> openCashier(int initialBalance) async {
    return Right(
      ShiftStatusEntity(
        isOpen: true,
        message: 'Buka kasir berhasil',
        shift: ShiftEntity(openingBalance: initialBalance),
      ),
    );
  }

  @override
  Future<Either<Failure, CloseCashierStatusEntity>> getCloseCashierStatus()
      async {
    return const Right(
      CloseCashierStatusEntity(
        canClose: true,
        message: 'Kasir dapat ditutup',
        pendingOrders: 0,
      ),
    );
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> closeCashier(
    int cashInDrawer,
  ) async {
    return Right(
      ShiftStatusEntity(
        isOpen: false,
        message: 'Tutup kasir berhasil',
        shift: ShiftEntity(
          closingBalance: cashInDrawer,
          isClosed: true,
        ),
      ),
    );
  }
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required ShiftRepository repository,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.openCashier,
    routes: [
      GoRoute(
        path: AppRoutes.openCashier,
        builder: (context, state) => const OpenCashierScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Dashboard Mock')),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shiftRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('OpenCashierScreen menampilkan informasi utama screen',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    expect(find.text('Buka Kasir'), findsWidgets);
    expect(find.byKey(const Key('open-cashier-submit-button')), findsOneWidget);
    expect(
      find.text('Silahkan masukkan jumlah saldo di laci'),
      findsOneWidget,
    );
    expect(find.text('Saldo Kasir'), findsOneWidget);
  });

  testWidgets('input nominal memperbarui preview format rupiah',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    await tester.enterText(
      find.byKey(const Key('open-cashier-amount-field')),
      '250000',
    );
    await tester.pumpAndSettle();

    expect(find.text('Rp 250.000'), findsOneWidget);
  });

  testWidgets('screen memprefill saldo dari buka kasir sebelumnya',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(
        lastOpeningBalance: 175000,
      ),
    );

    final amountField = tester.widget<TextField>(
      find.byKey(const Key('open-cashier-amount-field')),
    );

    expect(amountField.controller?.text, equals('175000'));
    expect(find.text('Rp 175.000'), findsOneWidget);
  });

  testWidgets('submit tanpa nominal menampilkan validasi lokal',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    await tester.tap(find.byKey(const Key('open-cashier-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Saldo Kasir wajib diisi'), findsOneWidget);
  });

  testWidgets('submit dengan nominal nol menampilkan validasi lokal',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    await tester.enterText(
      find.byKey(const Key('open-cashier-amount-field')),
      '0',
    );
    await tester.tap(find.byKey(const Key('open-cashier-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Saldo Kasir harus lebih besar dari nol'), findsOneWidget);
  });

  testWidgets('submit sukses mengarahkan pengguna ke dashboard', (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    await tester.enterText(
      find.byKey(const Key('open-cashier-amount-field')),
      '250000',
    );
    await tester.tap(find.byKey(const Key('open-cashier-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Mock'), findsOneWidget);
  });
}
