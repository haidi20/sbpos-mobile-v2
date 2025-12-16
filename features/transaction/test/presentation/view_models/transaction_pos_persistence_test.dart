import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:transaction/presentation/view_models/transaction_pos.persistence.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:core/core.dart';

class _FakeRepo implements TransactionRepository {
  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    return Right(transaction.copyWith(id: 1));
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    return Right(
        transaction.copyWith(totalAmount: transaction.totalAmount + 100));
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
      {bool? isOffline}) async {
    return Right(true);
  }

  // Unused methods required by interface – return sensible defaults
  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
          {bool? isOffline}) async =>
      Right(const []);

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
          {bool? isOffline}) async =>
      Left(UnknownFailure());

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
          {bool? isOffline}) async =>
      Left(UnknownFailure());

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
          {bool? isOffline, QueryGetTransactions? query}) async =>
      Right(const []);

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);
}

void main() {
  group('TransactionPersistence', () {
    late TransactionPersistence service;
    late TransactionPosState state;

    setUp(() {
      final repo = _FakeRepo();
      service = TransactionPersistence(
        CreateTransaction(repo),
        UpdateTransaction(repo),
        DeleteTransaction(repo),
        Logger('test'),
      );
      state = TransactionPosState();
    });

    test('creates transaction when no existing transaction', () async {
      final details = [
        TransactionDetailEntity(productId: 1, productPrice: 1000, qty: 2)
      ];
      TransactionPosState getState() => state;
      void setState(TransactionPosState s) => state = s;

      await service.persistAndUpdateState(
          () => getState(), (s) => setState(s), details);

      expect(state.transaction, isNotNull);
      expect(state.details.length, greaterThan(0));
      expect(state.isLoading, isFalse);
    });

    test('updates existing transaction when details not empty', () async {
      // prepare existing transaction in state
      state = state.copyWith(
          transaction: TransactionEntity(
        id: 2,
        outletId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 1000,
        totalQty: 1,
      ));

      final details = [
        TransactionDetailEntity(productId: 1, productPrice: 1000, qty: 1)
      ];
      await service.persistAndUpdateState(
          () => state, (s) => state = s, details);

      expect(state.transaction, isNotNull);
      expect(state.transaction!.totalAmount, greaterThanOrEqualTo(1000));
      expect(state.isLoading, isFalse);
    });

    test('deletes transaction when details empty', () async {
      state = state.copyWith(
          transaction: TransactionEntity(
        id: 3,
        outletId: 1,
        sequenceNumber: 2,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 500,
        totalQty: 1,
      ));

      final details = <TransactionDetailEntity>[];
      await service.persistAndUpdateState(
          () => state, (s) => state = s, details);

      expect(state.transaction, isNull);
      expect(state.details, isEmpty);
      expect(state.isLoading, isFalse);
    });
  });
}
