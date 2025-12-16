import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/presentation/components/order.card.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/components/summary_row.dart';
import 'package:transaction/presentation/screens/transaction_history.screen.dart';
import 'package:transaction/presentation/sheets/cart_bottom.sheet.dart';
import 'package:transaction/presentation/components/transaction.card.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/components/summary_row.card.dart';
import 'package:transaction/presentation/components/detail_info.card.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/presentation/screens/transaction_pos.screen.dart';
import 'package:transaction/presentation/sheets/transaction_detail.sheet.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/presentation/screens/transaction_history_detail.screen.dart';

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
          {bool? isOffline, QueryGetTransactions? query}) async =>
      const Right(<TransactionEntity>[]);

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
      {bool? isOffline}) async {
    final tx = TransactionEntity(
      outletId: 1,
      sequenceNumber: 1,
      orderTypeId: 1,
      date: DateTime.utc(2023, 1, 1),
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

// (No fakes required for current OrderCard constructor)

void main() {
  late FakeTransactionRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeTransactionRepository();
  });

  group('Transaction presentation widgets (smoke tests)', () {
    testWidgets('components render without error', (tester) async {
      await initializeDateFormatting();

      final tx = TransactionEntity(
        outletId: 1,
        sequenceNumber: 123,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 10000,
        totalQty: 2,
      );

      // Removed unused fakes since OrderCard no longer needs them

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            TransactionCard(tx: tx, onTap: () {}),
            SummaryRow(tx: tx),
            const SummaryRowCard(label: 'Card', value: 'Value'),
            OrderCard(
              id: 1,
              productName: 'Product A',
              productPrice: 10000.0,
              qty: 1,
              isActive: true,
              textController: TextEditingController(text: ''),
              focusNode: FocusNode(),
              onUpdateQuantity: (id, delta) {},
              onSetActiveNoteId: (id) {},
              onSetItemNote: (id, value) {},
            ),
            const DetailInfoCard(
                icon: Icons.info, label: 'Detail Item', value: 'Value'),
          ]),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(TransactionCard), findsOneWidget);
      expect(find.byType(SummaryRow), findsOneWidget);
      expect(find.text('Card'), findsWidgets);
      expect(find.text('Product A'), findsWidgets);
      expect(find.text('Detail Item'), findsOneWidget);
    });

    testWidgets('screens build with provider overrides', (tester) async {
      await initializeDateFormatting();

      // Provide both viewmodel overrides in a single ProviderScope to avoid
      // changing overrides mid-test (Riverpod limitation).
      await tester.pumpWidget(ProviderScope(overrides: [
        transactionHistoryViewModelProvider.overrideWith((ref) =>
            TransactionHistoryViewModel(GetTransactionsUsecase(fakeRepo))),
        transactionPosViewModelProvider.overrideWith((ref) =>
            TransactionPosViewModel(
                CreateTransaction(fakeRepo),
                UpdateTransaction(fakeRepo),
                DeleteTransaction(fakeRepo),
                GetTransactionActive(fakeRepo))),
      ], child: const MaterialApp(home: TransactionHistoryScreen())));

      await tester.pumpAndSettle();
      expect(find.byType(TransactionHistoryScreen), findsOneWidget);

      // POS screen reuse same ProviderScope; just rebuild the widget tree
      await tester.pumpWidget(ProviderScope(overrides: [
        transactionHistoryViewModelProvider.overrideWith((ref) =>
            TransactionHistoryViewModel(GetTransactionsUsecase(fakeRepo))),
        transactionPosViewModelProvider.overrideWith((ref) =>
            TransactionPosViewModel(
                CreateTransaction(fakeRepo),
                UpdateTransaction(fakeRepo),
                DeleteTransaction(fakeRepo),
                GetTransactionActive(fakeRepo))),
      ], child: const MaterialApp(home: TransactionPosScreen())));

      await tester.pumpAndSettle();
      expect(find.byType(TransactionPosScreen), findsOneWidget);

      // Cart bottom sheet
      await tester.pumpWidget(ProviderScope(overrides: [
        transactionHistoryViewModelProvider.overrideWith((ref) =>
            TransactionHistoryViewModel(GetTransactionsUsecase(fakeRepo))),
        transactionPosViewModelProvider.overrideWith((ref) =>
            TransactionPosViewModel(
                CreateTransaction(fakeRepo),
                UpdateTransaction(fakeRepo),
                DeleteTransaction(fakeRepo),
                GetTransactionActive(fakeRepo))),
      ], child: const MaterialApp(home: Scaffold(body: CartBottomSheet()))));

      await tester.pumpAndSettle();
      expect(find.byType(CartBottomSheet), findsOneWidget);
    });

    testWidgets('history detail screen and sheet render', (tester) async {
      await initializeDateFormatting();

      final tx = TransactionEntity(
        outletId: 1,
        sequenceNumber: 999,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 50000,
        totalQty: 3,
      );

      final details = <TransactionDetailEntity>[];

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: TransactionHistoryDetailScreen(tx: tx, details: details))));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionHistoryDetailScreen), findsOneWidget);

      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: TransactionDetailSheet(tx: tx))));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionDetailSheet), findsOneWidget);
    });
  });
}
