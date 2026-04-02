import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';
import 'package:transaction/presentation/providers/close_cashier.provider.dart';
import 'package:transaction/presentation/screens/close_cashier.screen.dart';

class _FakeShiftRepository implements ShiftRepository {
  _FakeShiftRepository({
    this.canClose = true,
    this.pendingOrders = 0,
    this.statusMessage = 'Kasir dapat ditutup',
  });

  final bool canClose;
  final int pendingOrders;
  final String statusMessage;

  @override
  Future<Either<Failure, ShiftStatusEntity>> getShiftStatus() async {
    return const Right(
      ShiftStatusEntity(
        isOpen: true,
        message: 'Shift sudah dibuka',
      ),
    );
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> openCashier(
    int initialBalance,
  ) async {
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
    return Right(
      CloseCashierStatusEntity(
        canClose: canClose,
        message: statusMessage,
        pendingOrders: pendingOrders,
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
    initialLocation: AppRoutes.closeCashier,
    routes: [
      GoRoute(
        path: AppRoutes.closeCashier,
        builder: (context, state) => const CloseCashierScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Mock')),
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
  testWidgets('CloseCashierScreen menampilkan informasi utama screen',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    expect(find.text('Tutup Kasir'), findsWidgets);
    expect(find.byKey(const Key('close-cashier-submit-button')), findsOneWidget);
    expect(
      find.text('Masukkan jumlah uang di laci sebelum menutup kasir'),
      findsOneWidget,
    );
    expect(find.text('Uang Di Kasir'), findsOneWidget);
  });

  testWidgets('input nominal memperbarui preview format rupiah',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    await tester.enterText(
      find.byKey(const Key('close-cashier-amount-field')),
      '350000',
    );
    await tester.pumpAndSettle();

    expect(find.text('Rp 350.000'), findsOneWidget);
  });

  testWidgets('submit tanpa nominal menampilkan validasi lokal',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    await tester.tap(find.byKey(const Key('close-cashier-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Uang Di Kasir wajib diisi'), findsOneWidget);
  });

  testWidgets('screen menampilkan warning saat masih ada pending order',
      (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(
        canClose: false,
        pendingOrders: 2,
        statusMessage: 'Masih ada pesanan pending',
      ),
    );

    expect(find.text('Masih ada pesanan pending'), findsOneWidget);
    expect(find.text('Pending order: 2'), findsOneWidget);
  });

  testWidgets('submit sukses mengarahkan pengguna ke login', (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeShiftRepository(),
    );

    await tester.enterText(
      find.byKey(const Key('close-cashier-amount-field')),
      '350000',
    );
    await tester.tap(find.byKey(const Key('close-cashier-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Login Mock'), findsOneWidget);
  });
}
