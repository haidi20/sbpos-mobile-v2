import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/cashier_category.entity.dart';
import 'package:transaction/domain/entitties/edit_order_check.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/entitties/order_type.entity.dart';
import 'package:transaction/domain/entitties/ojol_option.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_action.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/get_not_paid_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository(this.transactions);

  final List<TransactionEntity> transactions;

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
      Right(transactions);

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
      const Left(UnknownFailure());

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    bool? isOffline,
    QueryGetTransactions? query,
  }) async {
    var result = transactions;
    if (query?.search case final search? when search.isNotEmpty) {
      final lower = search.toLowerCase();
      result = result.where((item) {
        return (item.notes ?? '').toLowerCase().contains(lower) ||
            item.sequenceNumber.toString().contains(lower);
      }).toList();
    }
    return Right(result);
  }

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
  _FakeCashierRemoteRepository(this.notPaidTransactions);

  final List<TransactionEntity> notPaidTransactions;

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
      Right(notPaidTransactions);

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
  late TransactionHistoryViewModel viewModel;
  late TransactionEntity historyTransaction;
  late TransactionEntity notPaidTransaction;

  setUp(() {
    historyTransaction = TransactionEntity(
      id: 1,
      outletId: 1,
      sequenceNumber: 1001,
      orderTypeId: 1,
      date: DateTime.now(),
      totalAmount: 25000,
      totalQty: 1,
      status: TransactionStatus.lunas,
      notes: 'History order',
    );
    notPaidTransaction = TransactionEntity(
      id: 2,
      idServer: 99,
      outletId: 1,
      sequenceNumber: 2002,
      orderTypeId: 1,
      date: DateTime.now(),
      totalAmount: 30000,
      totalQty: 2,
      status: TransactionStatus.pending,
      notes: 'Offline order',
    );

    final transactionRepository = _FakeTransactionRepository(
      [historyTransaction],
    );
    final cashierRepository = _FakeCashierRemoteRepository(
      [notPaidTransaction],
    );
    viewModel = TransactionHistoryViewModel(
      GetTransactionsUsecase(transactionRepository),
      GetNotPaidTransactions(cashierRepository),
    );
  });

  test('onRefresh loads history and not paid transactions together', () async {
    await viewModel.onRefresh();

    expect(viewModel.state.transactions, [historyTransaction]);
    expect(viewModel.state.notPaidTransactions, [notPaidTransaction]);
    expect(viewModel.state.isLoading, isFalse);
    expect(viewModel.state.isLoadingNotPaid, isFalse);
  });

  test('setMode to notPaid exposes remote pending transactions', () async {
    await viewModel.onRefresh();
    await viewModel.setMode(TransactionHistoryMode.notPaid);

    expect(viewModel.state.mode, TransactionHistoryMode.notPaid);
    expect(viewModel.visibleTransactions, [notPaidTransaction]);
    expect(viewModel.isShowingNotPaid, isTrue);
  });

  test('visibleTransactions applies search query on selected mode source',
      () async {
    await viewModel.onRefresh();
    await viewModel.setMode(TransactionHistoryMode.notPaid);

    viewModel.onSearchChanged(
      '2002',
      debounce: Duration.zero,
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.visibleTransactions, [notPaidTransaction]);
  });
}
