import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/close_cashier_status.entity.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/domain/entitties/shift_status.entity.dart';
import 'package:transaction/domain/repositories/shift.repository.dart';
import 'package:transaction/presentation/providers/open_cashier.provider.dart';
import 'package:transaction/presentation/screens/open_cashier.screen.dart';
import 'package:transaction/presentation/widgets/open_cashier_guard.dart';

class _FakeShiftRepository implements ShiftRepository {
  _FakeShiftRepository(this.status);

  final ShiftStatusEntity status;

  @override
  Future<Either<Failure, ShiftStatusEntity>> getShiftStatus() async {
    return Right(status);
  }

  @override
  Future<Either<Failure, ShiftEntity?>> getLatestShift() async {
    return Right(status.shift);
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> openCashier(int initialBalance) async {
    return Right(status);
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
    return Right(status.copyWith(isOpen: false));
  }
}

class _DelayedShiftRepository implements ShiftRepository {
  _DelayedShiftRepository(this.futureStatus);

  final Future<ShiftStatusEntity> futureStatus;

  @override
  Future<Either<Failure, ShiftStatusEntity>> getShiftStatus() async {
    final status = await futureStatus;
    return Right(status);
  }

  @override
  Future<Either<Failure, ShiftEntity?>> getLatestShift() async {
    final status = await futureStatus;
    return Right(status.shift);
  }

  @override
  Future<Either<Failure, ShiftStatusEntity>> openCashier(
    int initialBalance,
  ) async {
    final status = await futureStatus;
    return Right(status);
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
    final status = await futureStatus;
    return Right(status.copyWith(isOpen: false));
  }
}

Future<void> _pumpGuard(
  WidgetTester tester, {
  required ShiftRepository repository,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const OpenCashierGuard(
          child: Scaffold(
            body: Center(child: Text('Dashboard Gate Child')),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.openCashier,
        builder: (context, state) => const OpenCashierScreen(),
      ),
      GoRoute(
        path: AppRoutes.closeCashier,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Close Cashier Mock')),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shiftRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('guard menampilkan loading saat pengecekan awal',
      (tester) async {
    final completer = Completer<ShiftStatusEntity>();
    final router = GoRouter(
      initialLocation: AppRoutes.dashboard,
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const OpenCashierGuard(
            child: Scaffold(
              body: Center(child: Text('Dashboard Gate Child')),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.openCashier,
          builder: (context, state) => const OpenCashierScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shiftRepositoryProvider.overrideWithValue(
            _DelayedShiftRepository(completer.future),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    expect(find.byKey(const Key('open-cashier-guard-loading')), findsOneWidget);

    completer.complete(
      const ShiftStatusEntity(
        isOpen: true,
        message: 'Shift sudah dibuka',
      ),
    );
  });

  testWidgets('guard mengarahkan ke screen buka kasir saat shift belum dibuka',
      (tester) async {
    await _pumpGuard(
      tester,
      repository: _FakeShiftRepository(
        const ShiftStatusEntity(
          isOpen: false,
          message: 'Shift belum dibuka',
        ),
      ),
    );

    expect(find.text('Buka Kasir'), findsWidgets);
    expect(find.byKey(const Key('open-cashier-submit-button')), findsOneWidget);
    expect(find.text('Dashboard Gate Child'), findsNothing);
  });

  testWidgets('guard meloloskan child saat shift sudah dibuka', (tester) async {
    await _pumpGuard(
      tester,
      repository: _FakeShiftRepository(
        const ShiftStatusEntity(
          isOpen: true,
          message: 'Shift sudah dibuka',
        ),
      ),
    );

    expect(find.text('Dashboard Gate Child'), findsOneWidget);
  });

  testWidgets('guard menampilkan popup konfirmasi saat shift beda hari',
      (tester) async {
    await _pumpGuard(
      tester,
      repository: _FakeShiftRepository(
        ShiftStatusEntity(
          isOpen: true,
          message: 'Shift lama masih aktif',
          shift: ShiftEntity(
            idServer: 11,
            shiftNumber: 1,
            date: DateTime.now().subtract(const Duration(days: 1)),
            isClosed: false,
          ),
        ),
      ),
    );

    expect(find.text('Dashboard Gate Child'), findsOneWidget);
    expect(find.text('Konfirmasi Tutup Kasir'), findsOneWidget);
    expect(
      find.text(
        'Shift aktif berasal dari hari sebelumnya. Apakah Anda ingin tutup kasir sekarang?',
      ),
      findsOneWidget,
    );
  });

  testWidgets('guard mengarahkan ke tutup kasir saat popup dikonfirmasi',
      (tester) async {
    await _pumpGuard(
      tester,
      repository: _FakeShiftRepository(
        ShiftStatusEntity(
          isOpen: true,
          message: 'Shift lama masih aktif',
          shift: ShiftEntity(
            idServer: 12,
            shiftNumber: 1,
            date: DateTime.now().subtract(const Duration(days: 1)),
            isClosed: false,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('different-day-close-cashier-yes')));
    await tester.pumpAndSettle();

    expect(find.text('Close Cashier Mock'), findsOneWidget);
  });

  testWidgets('guard menutup popup dan tetap di child saat memilih tidak',
      (tester) async {
    await _pumpGuard(
      tester,
      repository: _FakeShiftRepository(
        ShiftStatusEntity(
          isOpen: true,
          message: 'Shift lama masih aktif',
          shift: ShiftEntity(
            idServer: 13,
            shiftNumber: 1,
            date: DateTime.now().subtract(const Duration(days: 1)),
            isClosed: false,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('different-day-close-cashier-no')));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Gate Child'), findsOneWidget);
    expect(find.text('Konfirmasi Tutup Kasir'), findsNothing);
  });
}
