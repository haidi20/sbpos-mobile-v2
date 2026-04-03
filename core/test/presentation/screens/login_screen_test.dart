import 'package:core/core.dart';
import 'package:core/domain/entities/user_entity.dart';
import 'package:core/domain/repositories/auth_repository.dart';
import 'package:core/presentation/providers/auth_repository_provider.dart';
import 'package:core/presentation/screens/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.onStoreLogin,
  });

  final Future<Either<Failure, UserEntity>> Function({
    required String email,
    required String password,
  })? onStoreLogin;

  @override
  Future<Either<Failure, bool>> logout() async => const Right(true);

  @override
  Future<Either<Failure, UserEntity>> refreshSession() async {
    return const Left(ServerValidation('Tidak ada sesi'));
  }

  @override
  Future<Either<Failure, UserEntity>> storeLogin({
    required String email,
    required String password,
  }) {
    final handler = onStoreLogin;
    if (handler == null) {
      return Future.value(
        const Right(
          UserEntity(
            id: 1,
            username: 'kasir',
            email: 'kasir@demo.com',
            token: 'token',
          ),
        ),
      );
    }
    return handler(email: email, password: password);
  }
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  required AuthRepository repository,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Dashboard Mock'),
          ),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login screen shows validation when credentials are empty',
      (tester) async {
    await _pumpLogin(
      tester,
      repository: _FakeAuthRepository(),
    );

    await tester.tap(find.text('Masuk Aplikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Email dan password harus diisi'), findsOneWidget);
  });

  testWidgets('login screen shows validation when password is too short', (tester) async {
    await _pumpLogin(
      tester,
      repository: _FakeAuthRepository(),
    );

    // Enter email but short password
    await tester.enterText(
      find.byType(TextFormField).first,
      'kasir@demo.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      '123',
    );

    await tester.tap(find.text('Masuk Aplikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Password minimal 6 karakter'), findsOneWidget);
  });

  testWidgets('forgot password button shows guidance snackbar', (tester) async {
    await _pumpLogin(
      tester,
      repository: _FakeAuthRepository(),
    );

    await tester.tap(find.text('Lupa Password?'));
    await tester.pumpAndSettle();

    expect(
      find.text('Silakan hubungi Admin untuk proses reset password.'),
      findsOneWidget,
    );
  });

  testWidgets('successful login navigates to dashboard', (tester) async {
    await _pumpLogin(
      tester,
      repository: _FakeAuthRepository(
        onStoreLogin: ({required email, required password}) async {
          expect(email, 'kasir@demo.com');
          expect(password, 'kasirdemo');
          return const Right(
            UserEntity(
              id: 1,
              username: 'Kasir',
              email: 'kasir@demo.com',
              token: 'jwt-token',
              refreshToken: 'refresh-token',
            ),
          );
        },
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'kasir@demo.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'kasirdemo',
    );
    await tester.tap(find.text('Masuk Aplikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Mock'), findsOneWidget);
  });

  testWidgets(
      '[TDD] Alur User: Membuka aplikasi, melihat Login Halaman Awal, memasukkan Email & Password, dan tekan Login',
      (tester) async {
    await _pumpLogin(
      tester,
      repository: _FakeAuthRepository(
        onStoreLogin: ({required email, required password}) async {
          expect(email, 'kasir@demo.com');
          expect(password, 'kasirdemo');
          return const Right(
            UserEntity(
              id: 1,
              username: 'Kasir',
              email: 'kasir@demo.com',
              token: 'jwt-token',
            ),
          );
        },
      ),
    );

    // Langkah 1: Pengguna membuka aplikasi dan disajikan dengan layar Login
    // Memastikan logo SBPOS dan slogan tampil
    expect(find.text('SBPOS', findRichText: true), findsOneWidget);
    expect(find.text('Solusi Pintar Bisnis Anda'), findsOneWidget);
    // Memastikan field input ada
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Masuk Aplikasi'), findsOneWidget);

    // Langkah 2: Pengguna memasukkan Email dan Password
    await tester.enterText(
      find.byType(TextFormField).first,
      'kasir@demo.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'kasirdemo',
    );

    // Langkah 3: Menekan tombol "Login" (Masuk Aplikasi)
    await tester.tap(find.text('Masuk Aplikasi'));
    await tester.pumpAndSettle();

    // Memastikan sukses login memanggil API dan navigasi
    expect(find.text('Dashboard Mock'), findsOneWidget);
  });
}
