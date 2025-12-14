import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/presentation/screens/transaction_history.screen.dart';
import 'package:transaction/presentation/screens/transaction_pos.screen.dart';
import 'package:transaction/presentation/sheets/cart_bottom.sheet.dart';
import 'package:transaction/presentation/screens/transaction_history_detail.screen.dart';
import 'package:transaction/presentation/sheets/transaction_detail.sheet.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions_offline.usecase.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';

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
      outletId: 1,
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
      outletId: 1,
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
  final fakeRepo = FakeTransactionRepository();

  group('Transaction presentation screens', () {
    testWidgets('TransactionHistoryScreen builds with provider override',
        (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: [
        transactionHistoryViewModelProvider.overrideWith((ref) =>
            TransactionHistoryViewModel(GetTransactionsUsecase(fakeRepo),
                GetTransactionsOffline(fakeRepo))),
      ], child: const MaterialApp(home: TransactionHistoryScreen())));

      await tester.pumpAndSettle();
      expect(find.text('Riwayat Transaksi'), findsOneWidget);
    });

    testWidgets('TransactionPosScreen builds with pos provider override',
        (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: [
        transactionPosViewModelProvider.overrideWith((ref) =>
            TransactionPosViewModel(
                CreateTransaction(fakeRepo),
                UpdateTransaction(fakeRepo),
                DeleteTransaction(fakeRepo),
                GetTransactionActive(fakeRepo))),
      ], child: const MaterialApp(home: TransactionPosScreen())));

      await tester.pumpAndSettle();
      expect(find.text('POS Produk'), findsOneWidget);
    });

    testWidgets('CartBottomSheet builds with pos provider override',
        (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: [
        transactionPosViewModelProvider.overrideWith((ref) =>
            TransactionPosViewModel(
                CreateTransaction(fakeRepo),
                UpdateTransaction(fakeRepo),
                DeleteTransaction(fakeRepo),
                GetTransactionActive(fakeRepo))),
      ], child: const MaterialApp(home: Scaffold(body: CartBottomSheet()))));

      await tester.pumpAndSettle();
      expect(find.textContaining('Pesanan'), findsWidgets);
    });

    testWidgets('TransactionHistoryDetailScreen and DetailSheet build',
        (tester) async {
      await initializeDateFormatting();
      final tx = TransactionEntity(
        outletId: 1,
        sequenceNumber: 123,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 10000,
        totalQty: 2,
      );
      final details = <TransactionDetailEntity>[];

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: TransactionHistoryDetailScreen(tx: tx, details: details))));
      await tester.pumpAndSettle();
      expect(find.text('Detail Transaksi'), findsWidgets);

      // TransactionDetailSheet
      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: TransactionDetailSheet(tx: tx))));
      await tester.pumpAndSettle();
      expect(find.text('Detail Transaksi'), findsWidgets);
    });
  });
}
