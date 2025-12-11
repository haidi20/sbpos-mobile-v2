import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/screens/transaction.screen.dart';
import 'package:transaction/presentation/view_models/transaction.vm.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/domain/usecases/get_transactions_offline.usecase.dart';

class RepoWithOneTransaction implements TransactionRepository {
  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
          {bool? isOffline}) async =>
      Right(_sampleList());

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
          {bool? isOffline}) async =>
      Right(_sampleList());

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
          {bool? isOffline}) async =>
      Right(_sampleTx(1));

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
          {bool? isOffline}) async =>
      Right(_sampleTx(id));

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
  Future<Either<Failure, TransactionEntity>> updateTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
          {bool? isOffline}) async =>
      const Right(true);

  List<TransactionEntity> _sampleList() => [_sampleTx(1)];

  TransactionEntity _sampleTx(int seq) {
    return TransactionEntity(
      outletId: 1,
      sequenceNumber: seq,
      orderTypeId: 1,
      date: DateTime(2025, 1, 1, 12, 0),
      totalAmount: 15000,
      totalQty: 3,
      paymentMethod: 'cash',
      categoryOrder: 'Umum',
      notes: 'Test note',
    );
  }
}

void main() {
  testWidgets('Tapping TransactionCard opens detail bottom sheet safely',
      (tester) async {
    final repo = RepoWithOneTransaction();

    // Build with provider override using our repo-driven VM
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionViewModelProvider
              .overrideWith((ref) => TransactionViewModel(
                    GetTransactionsUsecase(repo),
                    GetTransactionsOffline(repo),
                  )),
        ],
        child: const MaterialApp(home: TransactionScreen()),
      ),
    );

    // Allow initState post-frame refresh
    await tester.pumpAndSettle();

    // Ensure one card rendered
    expect(find.text('Order #1'), findsOneWidget);

    // Tap the card (any child inside InkWell will bubble to onTap)
    await tester.tap(find.text('Lihat Detail'));
    await tester.pumpAndSettle();

    // Bottom sheet appears with expected content
    expect(find.text('Detail Transaksi'), findsOneWidget);
    expect(find.text('Cetak Struk'), findsOneWidget);

    // SafeArea should be present in the sheet subtree
    expect(find.byType(SafeArea), findsWidgets);
  });
}
