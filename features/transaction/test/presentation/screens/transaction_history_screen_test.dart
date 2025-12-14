import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:transaction/presentation/screens/transaction_history.screen.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions_offline.usecase.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';

class _FakeRepo implements TransactionRepository {
  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
          {bool? isOffline}) async =>
      Right([]);

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
          {bool? isOffline}) async =>
      Right([]);

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
          {bool? isOffline}) async =>
      Right(TransactionEntity(
          outletId: 1,
          sequenceNumber: 1,
          orderTypeId: 1,
          date: DateTime.now(),
          totalAmount: 0,
          totalQty: 0));

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
          {bool? isOffline}) async =>
      Right(TransactionEntity(
          outletId: 1,
          sequenceNumber: id,
          orderTypeId: 1,
          date: DateTime.now(),
          totalAmount: 0,
          totalQty: 0));

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
          {bool? isOffline}) async =>
      Right(true);
}

void main() {
  testWidgets('TransactionHistoryScreen builds without exceptions',
      (WidgetTester tester) async {
    final fake = _FakeRepo();

    await tester.pumpWidget(ProviderScope(
        overrides: [
          transactionHistoryViewModelProvider.overrideWith((ref) =>
              TransactionHistoryViewModel(
                  GetTransactionsUsecase(fake), GetTransactionsOffline(fake))),
        ],
        child: const MaterialApp(
            home: Scaffold(body: TransactionHistoryScreen()))));

    await tester.pumpAndSettle();

    // screen should contain title
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
  });

  testWidgets('Date tabs default to today and selecting Kemarin updates state',
      (WidgetTester tester) async {
    final fake = _FakeRepo();
    late TransactionHistoryViewModel vm;

    await tester.pumpWidget(ProviderScope(
        overrides: [
          transactionHistoryViewModelProvider.overrideWith((ref) {
            vm = TransactionHistoryViewModel(
                GetTransactionsUsecase(fake), GetTransactionsOffline(fake));
            return vm;
          }),
        ],
        child: const MaterialApp(
            home: Scaffold(body: TransactionHistoryScreen()))));

    await tester.pumpAndSettle();

    // initial selectedDate should be today
    final now = DateTime.now();
    expect(vm.state.selectedDate?.year, now.year);
    expect(vm.state.selectedDate?.month, now.month);
    expect(vm.state.selectedDate?.day, now.day);

    // tap Kemarin tab
    final kemarinFinder = find.widgetWithText(ChoiceChip, 'Kemarin');
    expect(kemarinFinder, findsOneWidget);
    await tester.tap(kemarinFinder);
    await tester.pumpAndSettle();

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    expect(vm.state.selectedDate?.year, yesterday.year);
    expect(vm.state.selectedDate?.month, yesterday.month);
    expect(vm.state.selectedDate?.day, yesterday.day);
  });
}
