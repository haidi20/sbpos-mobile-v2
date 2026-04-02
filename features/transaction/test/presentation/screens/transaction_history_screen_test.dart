import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/entitties/edit_order_check.entity.dart';
import 'package:transaction/domain/entitties/order_type.entity.dart';
import 'package:transaction/domain/entitties/ojol_option.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_action.entity.dart';
import 'package:transaction/domain/entitties/cashier_category.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/get_not_paid_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/screens/transaction_history.screen.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository({
    List<TransactionEntity>? transactions,
  }) : _transactions = transactions ?? const [];

  final List<TransactionEntity> _transactions;

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) async =>
      Right(transaction);

  @override
  Future<Either<Failure, bool>> deleteTransaction(
    int id, {
    bool? isOffline,
  }) async =>
      const Right(true);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions({
    bool? isOffline,
  }) async =>
      Right(_transactions);

  @override
  Future<Either<Failure, int>> getLastSequenceNumber({bool? isOffline}) async =>
      const Right(0);

  @override
  Future<Either<Failure, TransactionEntity>> getPendingTransaction({
    bool? isOffline,
  }) async =>
      const Left(UnknownFailure());

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(
    int id, {
    bool? isOffline,
  }) async =>
      _transactions.where((item) => item.id == id).isEmpty
          ? const Left(UnknownFailure())
          : Right(_transactions.firstWhere((item) => item.id == id));

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    bool? isOffline,
    QueryGetTransactions? query,
  }) async =>
      Right(_transactions);

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) async =>
      Right(transaction);

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) async =>
      Right(transaction);
}

class _FakeCashierRemoteRepository implements CashierRemoteRepository {
  _FakeCashierRemoteRepository({
    List<TransactionEntity>? notPaidTransactions,
  }) : _notPaidTransactions = notPaidTransactions ?? const [];

  final List<TransactionEntity> _notPaidTransactions;

  @override
  Future<Either<Failure, bool>> checkTransactionQty({
    required int productId,
    required int qty,
  }) async =>
      const Right(true);

  @override
  Future<Either<Failure, TransactionEntity>> checkoutTransaction(
    TransactionEntity transaction, {
    required bool isOnline,
  }) async =>
      Right(transaction);

  @override
  Future<Either<Failure, EditOrderCheckEntity>> checkEditOrder(
    int transactionId,
  ) async =>
      const Left(UnknownFailure());

  @override
  Future<Either<Failure, TransactionActionEntity>> confirmCancelTransaction({
    required int transactionId,
    required String otp,
  }) async =>
      const Left(UnknownFailure());

  @override
  Future<Either<Failure, List<CashierCategoryEntity>>> getCustomCategories() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getNotPaidTransactions() async =>
      Right(_notPaidTransactions);

  @override
  Future<Either<Failure, List<OjolOptionEntity>>> getOjolOptions() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<OrderTypeEntity>>> getOrderTypes() async =>
      const Right([]);

  @override
  Future<Either<Failure, TransactionActionEntity>> requestCancelTransaction({
    required int transactionId,
    required String reason,
  }) async =>
      const Left(UnknownFailure());
}

void main() {
  testWidgets('TransactionHistoryScreen builds without exceptions',
      (WidgetTester tester) async {
    final historyRepository = _FakeTransactionRepository();
    final remoteRepository = _FakeCashierRemoteRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionHistoryViewModelProvider.overrideWith(
            (ref) => TransactionHistoryViewModel(
              GetTransactionsUsecase(historyRepository),
              GetNotPaidTransactions(remoteRepository),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: TransactionHistoryScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Pesanan Offline'), findsOneWidget);
  });

  testWidgets('Date tabs default to today and selecting Kemarin updates state',
      (WidgetTester tester) async {
    final historyRepository = _FakeTransactionRepository();
    final remoteRepository = _FakeCashierRemoteRepository();
    late TransactionHistoryViewModel vm;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionHistoryViewModelProvider.overrideWith((ref) {
            vm = TransactionHistoryViewModel(
              GetTransactionsUsecase(historyRepository),
              GetNotPaidTransactions(remoteRepository),
            );
            return vm;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(body: TransactionHistoryScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final now = DateTime.now();
    expect(vm.state.selectedDate?.year, now.year);
    expect(vm.state.selectedDate?.month, now.month);
    expect(vm.state.selectedDate?.day, now.day);

    final kemarinFinder = find.text('Kemarin');
    expect(kemarinFinder, findsOneWidget);
    await tester.tap(kemarinFinder);
    await tester.pumpAndSettle();

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    expect(vm.state.selectedDate?.year, yesterday.year);
    expect(vm.state.selectedDate?.month, yesterday.month);
    expect(vm.state.selectedDate?.day, yesterday.day);
  });

  testWidgets('switching to Pesanan Offline renders remote not paid orders',
      (WidgetTester tester) async {
    final notPaidTransaction = TransactionEntity(
      id: 99,
      idServer: 120,
      outletId: 1,
      sequenceNumber: 9001,
      orderTypeId: 1,
      date: DateTime.now(),
      totalAmount: 45000,
      totalQty: 2,
      status: TransactionStatus.pending,
      paymentMethod: 'cash',
      categoryOrder: 'DINE_IN',
    );
    final historyRepository = _FakeTransactionRepository();
    final remoteRepository = _FakeCashierRemoteRepository(
      notPaidTransactions: [notPaidTransaction],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionHistoryViewModelProvider.overrideWith(
            (ref) => TransactionHistoryViewModel(
              GetTransactionsUsecase(historyRepository),
              GetNotPaidTransactions(remoteRepository),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: TransactionHistoryScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Pesanan Offline'));
    await tester.pumpAndSettle();

    expect(find.text('Pesanan #9001'), findsOneWidget);
    expect(find.text('Rp 45.000'), findsOneWidget);
  });
}
