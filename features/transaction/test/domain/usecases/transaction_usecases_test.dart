import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/usecases/get_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';

class FakeTransactionRepository implements TransactionRepository {
  final bool shouldFail;
  FakeTransactionRepository({this.shouldFail = false});

  TransactionEntity _sampleEntity() => TransactionEntity(
        id: 1,
        warehouseId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 100,
        totalQty: 1,
        details: [
          const TransactionDetailEntity(
            productId: 10,
            productName: 'Sample',
            productPrice: 100,
            qty: 1,
            subtotal: 100,
          )
        ],
      );

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    if (shouldFail) return const Left(UnknownFailure());
    return Right(_sampleEntity());
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
      {bool? isOffline}) async {
    if (shouldFail) return const Left(UnknownFailure());
    return Right([_sampleEntity()]);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline}) async {
    if (shouldFail) return const Left(UnknownFailure());
    return Right(_sampleEntity());
  }

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
      {bool? isOffline}) async {
    if (shouldFail) return const Left(UnknownFailure());
    return Right(_sampleEntity());
  }

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    if (shouldFail) return const Left(UnknownFailure());
    return Right(transaction);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
      {bool? isOffline}) async {
    return getDataTransactions(isOffline: isOffline);
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
      {bool? isOffline}) async {
    if (shouldFail) return const Left(UnknownFailure());
    return const Right(true);
  }
}

void main() {
  group('Transaction usecases', () {
    late FakeTransactionRepository repo;

    setUp(() {
      repo = FakeTransactionRepository();
    });

    test('CreateTransaction returns entity on success', () async {
      final usecase = CreateTransaction(repo);
      final tx = TransactionEntity(
        warehouseId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 10,
        totalQty: 1,
      );

      final res = await usecase.call(tx, isOffline: true);
      expect(res.isRight(), true);
      res.fold((l) => fail('expected right'),
          (r) => expect(r.totalAmount, isNotNull));
    });

    test('GetTransactionsUsecase returns list on success', () async {
      final usecase = GetTransactionsUsecase(repo);
      final res = await usecase.call(isOffline: true);
      expect(res.isRight(), true);
      res.fold(
          (l) => fail('expected right'), (list) => expect(list, isNotEmpty));
    });

    test('GetTransaction returns entity on success', () async {
      final usecase = GetTransaction(repo);
      final res = await usecase.call(1, isOffline: true);
      expect(res.isRight(), true);
      res.fold((l) => fail('expected right'), (r) => expect(r.id, equals(1)));
    });

    test('UpdateTransaction returns updated entity', () async {
      final usecase = UpdateTransaction(repo);
      final tx = TransactionEntity(
        id: 1,
        warehouseId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 20,
        totalQty: 2,
      );
      final res = await usecase.call(tx, isOffline: true);
      expect(res.isRight(), true);
      res.fold((l) => fail('expected right'),
          (r) => expect(r.totalAmount, equals(20)));
    });

    test('DeleteTransaction returns true on success', () async {
      final usecase = DeleteTransaction(repo);
      final res = await usecase.call(1, isOffline: true);
      expect(res.isRight(), true);
      res.fold((l) => fail('expected right'), (r) => expect(r, isTrue));
    });
  });
}
