import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/presentation/screens/transaction.screen.dart';
import 'package:transaction/presentation/view_models/transaction.vm.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions_offline.usecase.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
// dartz and Riverpod types are re-exported from `package:core/core.dart`.
// Avoid importing packages that are already exposed by `core`.

class FakeTransactionRepository implements TransactionRepository {
  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
          {bool? isOffline}) async =>
      const Right(<TransactionEntity>[]);

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
      const Right(<TransactionEntity>[]);

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
      {bool? isOffline}) async {
    final tx = TransactionEntity(
      warehouseId: 1,
      sequenceNumber: 1,
      orderTypeId: 1,
      date: DateTime.now(),
      totalAmount: 0,
      totalQty: 0,
    );
    return Right(tx);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline}) async {
    final tx = TransactionEntity(
      warehouseId: 1,
      sequenceNumber: id,
      orderTypeId: 1,
      date: DateTime.now(),
      totalAmount: 0,
      totalQty: 0,
    );
    return Right(tx);
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
          {bool? isOffline}) async =>
      const Right(true);
}

void main() {
  testWidgets('TransactionScreen pumps without provider-modify exceptions',
      (tester) async {
    final fakeRepo = FakeTransactionRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // override the original provider with one using fakes
          transactionViewModelProvider
              .overrideWith((ref) => TransactionViewModel(
                    GetTransactionsUsecase(fakeRepo),
                    GetTransactionsOffline(fakeRepo),
                  )),
        ],
        child: const MaterialApp(home: TransactionScreen()),
      ),
    );

    // Allow post-frame callbacks to run
    await tester.pumpAndSettle();

    // If no uncaught exceptions happened, test passes
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
  });
}
