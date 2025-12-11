import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/get_transactions_offline.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/presentation/view_models/transaction.vm.dart';

class _FakeRepoForOffline implements TransactionRepository {
  final List<TransactionEntity> local;
  _FakeRepoForOffline(this.local);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions({
    bool? isOffline,
  }) async {
    return Right(local);
  }

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
      {bool? isOffline}) async {
    return Right(local);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
      {bool? isOffline}) async {
    return const Left(UnknownFailure());
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline}) async {
    return const Left(UnknownFailure());
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    return Right(transaction);
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
      {bool? isOffline}) async {
    return const Right(true);
  }
}

void main() {
  test('refresh() loads transactions from local DB via GetTransactionsOffline',
      () async {
    // Arrange - prepare local transaction
    final tx = TransactionEntity(
      id: 1,
      outletId: 8,
      sequenceNumber: 1,
      orderTypeId: 1,
      date: DateTime.now(),
      totalAmount: 15000,
      totalQty: 1,
      notes: 'local tx',
      details: [
        const TransactionDetailEntity(
          productId: 101,
          productName: 'Local Product',
          productPrice: 15000,
          qty: 1,
          subtotal: 15000,
          transactionId: 1,
        ),
      ],
    );

    final fakeRepo = _FakeRepoForOffline([tx]);
    final getOffline = GetTransactionsOffline(fakeRepo);

    // TransactionViewModel expects a GetTransactionsUsecase as first param.
    final getAllUsecase = GetTransactionsUsecase(fakeRepo);
    final vm = TransactionViewModel(getAllUsecase, getOffline);

    // Act
    await vm.refresh();

    // Assert
    expect(vm.state.isLoading, isFalse);
    expect(vm.state.error, isNull);
    expect(vm.state.transactions, isNotEmpty);
    expect(vm.state.transactions.first.id, equals(1));
    expect(vm.state.transactions.first.details, isNotEmpty);
    expect(vm.state.transactions.first.details!.first.productId, equals(101));
  });
}

// no dummy needed
