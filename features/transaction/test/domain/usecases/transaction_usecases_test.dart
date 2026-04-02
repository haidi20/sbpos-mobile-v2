import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_last_secuence_number_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository({
    this.onCreateTransaction,
    this.onDeleteTransaction,
    this.onGetLastSequenceNumber,
    this.onGetPendingTransaction,
    this.onGetTransaction,
    this.onGetTransactions,
    this.onSetTransaction,
    this.onUpdateTransaction,
  });

  final Future<Either<Failure, TransactionEntity>> Function(
    TransactionEntity transaction, {
    bool? isOffline,
  })? onCreateTransaction;
  final Future<Either<Failure, bool>> Function(
    int id, {
    bool? isOffline,
  })? onDeleteTransaction;
  final Future<Either<Failure, int>> Function({bool? isOffline})?
      onGetLastSequenceNumber;
  final Future<Either<Failure, TransactionEntity>> Function({
    bool? isOffline,
  })? onGetPendingTransaction;
  final Future<Either<Failure, TransactionEntity>> Function(
    int id, {
    bool? isOffline,
  })? onGetTransaction;
  final Future<Either<Failure, List<TransactionEntity>>> Function({
    bool? isOffline,
    QueryGetTransactions? query,
  })? onGetTransactions;
  final Future<Either<Failure, TransactionEntity>> Function(
    TransactionEntity transaction, {
    bool? isOffline,
  })? onSetTransaction;
  final Future<Either<Failure, TransactionEntity>> Function(
    TransactionEntity transaction, {
    bool? isOffline,
  })? onUpdateTransaction;

  static TransactionEntity sampleTransaction({
    int id = 1,
    int sequenceNumber = 1,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id,
      outletId: 1,
      sequenceNumber: sequenceNumber,
      orderTypeId: 1,
      date: DateTime(2026, 4, 2, 10),
      totalAmount: 10000,
      totalQty: 1,
      status: TransactionStatus.pending,
      createdAt: createdAt,
      details: const [
        TransactionDetailEntity(
          productId: 10,
          productName: 'Es Teh',
          productPrice: 10000,
          qty: 1,
          subtotal: 10000,
        ),
      ],
    );
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) {
    final handler = onCreateTransaction;
    if (handler == null) {
      return Future.value(Right(transaction));
    }
    return handler(transaction, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id, {bool? isOffline}) {
    final handler = onDeleteTransaction;
    if (handler == null) {
      return Future.value(const Right(true));
    }
    return handler(id, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions({
    bool? isOffline,
  }) {
    return getTransactions(isOffline: isOffline);
  }

  @override
  Future<Either<Failure, int>> getLastSequenceNumber({bool? isOffline}) {
    final handler = onGetLastSequenceNumber;
    if (handler == null) {
      return Future.value(const Right(12));
    }
    return handler(isOffline: isOffline);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getPendingTransaction({
    bool? isOffline,
  }) {
    final handler = onGetPendingTransaction;
    if (handler == null) {
      return Future.value(Right(sampleTransaction(id: 99, sequenceNumber: 9)));
    }
    return handler(isOffline: isOffline);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(
    int id, {
    bool? isOffline,
  }) {
    final handler = onGetTransaction;
    if (handler == null) {
      return Future.value(Right(sampleTransaction(id: id)));
    }
    return handler(id, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    bool? isOffline,
    QueryGetTransactions? query,
  }) {
    final handler = onGetTransactions;
    if (handler == null) {
      return Future.value(
        Right([
          sampleTransaction(
            id: 1,
            sequenceNumber: 1,
            createdAt: DateTime(2026, 4, 2, 8),
          ),
          sampleTransaction(
            id: 2,
            sequenceNumber: 3,
            createdAt: DateTime(2026, 4, 2, 9),
          ),
          sampleTransaction(
            id: 3,
            sequenceNumber: 2,
            createdAt: DateTime(2026, 4, 2, 9),
          ),
        ]),
      );
    }
    return handler(isOffline: isOffline, query: query);
  }

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) {
    final handler = onSetTransaction;
    if (handler == null) {
      return Future.value(Right(transaction));
    }
    return handler(transaction, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) {
    final handler = onUpdateTransaction;
    if (handler == null) {
      return Future.value(Right(transaction));
    }
    return handler(transaction, isOffline: isOffline);
  }
}

Future<void> expectLeftFailure<T>(
  Future<Either<Failure, T>> Function() action,
  Matcher matcher,
) async {
  final result = await action();
  result.fold(
    (failure) => expect(failure, matcher),
    (_) => fail('Expected Left result'),
  );
}

void main() {
  group('Transaction usecases', () {
    test('CreateTransaction returns entity with pending status on success',
        () async {
      TransactionEntity? capturedTransaction;
      final repository = FakeTransactionRepository(
        onCreateTransaction: (transaction, {isOffline}) async {
          capturedTransaction = transaction;
          return Right(transaction);
        },
      );
      final draft = FakeTransactionRepository.sampleTransaction(
        id: 10,
        sequenceNumber: 5,
      ).copyWith(status: TransactionStatus.lunas);

      final result =
          await CreateTransaction(repository)(draft, isOffline: true);

      expect(capturedTransaction?.status, TransactionStatus.pending);
      result.fold(
        (_) => fail('Expected Right result'),
        (transaction) => expect(transaction.status, TransactionStatus.pending),
      );
    });

    test(
        'GetTransactionsUsecase sorts transactions by createdAt desc then sequence desc',
        () async {
      final repository = FakeTransactionRepository();

      final result = await GetTransactionsUsecase(repository)(
        isOffline: true,
      );

      result.fold(
        (_) => fail('Expected Right result'),
        (transactions) => expect(
          transactions.map((item) => item.id).toList(),
          [2, 3, 1],
        ),
      );
    });

    test('GetTransaction returns entity on success', () async {
      final repository = FakeTransactionRepository();

      final result = await GetTransaction(repository)(7, isOffline: true);

      result.fold(
        (_) => fail('Expected Right result'),
        (transaction) => expect(transaction.id, 7),
      );
    });

    test('GetTransactionActive returns pending transaction on success',
        () async {
      final repository = FakeTransactionRepository();

      final result = await GetTransactionActive(repository)(isOffline: true);

      result.fold(
        (_) => fail('Expected Right result'),
        (transaction) => expect(transaction.status, TransactionStatus.pending),
      );
    });

    test('UpdateTransaction returns updated entity on success', () async {
      final repository = FakeTransactionRepository();
      final transaction = FakeTransactionRepository.sampleTransaction(
        id: 5,
        sequenceNumber: 8,
      ).copyWith(totalAmount: 25000);

      final result = await UpdateTransaction(repository)(
        transaction,
        isOffline: true,
      );

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value.totalAmount, 25000),
      );
    });

    test('DeleteTransaction returns true on success', () async {
      final repository = FakeTransactionRepository();

      final result = await DeleteTransaction(repository)(3, isOffline: true);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, isTrue),
      );
    });

    test('GetLastSequenceNumberTransaction returns latest sequence on success',
        () async {
      final repository = FakeTransactionRepository();

      final result =
          await GetLastSequenceNumberTransaction(repository)(isOffline: true);

      expect(result, 12);
    });

    test(
        'GetLastSequenceNumberTransaction returns 0 when repository returns Left',
        () async {
      final repository = FakeTransactionRepository(
        onGetLastSequenceNumber: ({isOffline}) async =>
            const Left(ServerFailure()),
      );

      final result =
          await GetLastSequenceNumberTransaction(repository)(isOffline: true);

      expect(result, 0);
    });

    test('GetLastSequenceNumberTransaction returns 0 on unexpected exception',
        () async {
      final repository = FakeTransactionRepository(
        onGetLastSequenceNumber: ({isOffline}) => Future.error(
          Exception('boom'),
        ),
      );

      final result =
          await GetLastSequenceNumberTransaction(repository)(isOffline: true);

      expect(result, 0);
    });

    test('CreateTransaction maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeTransactionRepository(
        onCreateTransaction: (transaction, {isOffline}) =>
            Future.error(failure),
      );
      final draft = FakeTransactionRepository.sampleTransaction(id: 10);

      await expectLeftFailure(
        () => CreateTransaction(repository)(draft, isOffline: true),
        same(failure),
      );
    });

    test('CreateTransaction maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeTransactionRepository(
        onCreateTransaction: (transaction, {isOffline}) =>
            Future.error(Exception('boom')),
      );
      final draft = FakeTransactionRepository.sampleTransaction(id: 10);

      await expectLeftFailure(
        () => CreateTransaction(repository)(draft, isOffline: true),
        isA<UnknownFailure>(),
      );
    });

    test('GetTransaction maps thrown Failure into Left', () async {
      const failure = NetworkFailure();
      final repository = FakeTransactionRepository(
        onGetTransaction: (id, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetTransaction(repository)(1, isOffline: true),
        same(failure),
      );
    });

    test('GetTransaction maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeTransactionRepository(
        onGetTransaction: (id, {isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetTransaction(repository)(1, isOffline: true),
        isA<UnknownFailure>(),
      );
    });

    test('GetTransactionsUsecase maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeTransactionRepository(
        onGetTransactions: ({isOffline, query}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetTransactionsUsecase(repository)(isOffline: true),
        same(failure),
      );
    });

    test('GetTransactionsUsecase maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeTransactionRepository(
        onGetTransactions: ({isOffline, query}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetTransactionsUsecase(repository)(isOffline: true),
        isA<UnknownFailure>(),
      );
    });

    test('GetTransactionActive maps thrown Failure into Left', () async {
      const failure = LocalValidation('transaksi aktif tidak ditemukan');
      final repository = FakeTransactionRepository(
        onGetPendingTransaction: ({isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetTransactionActive(repository)(isOffline: true),
        same(failure),
      );
    });

    test('GetTransactionActive maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeTransactionRepository(
        onGetPendingTransaction: ({isOffline}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetTransactionActive(repository)(isOffline: true),
        isA<UnknownFailure>(),
      );
    });

    test('UpdateTransaction maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeTransactionRepository(
        onUpdateTransaction: (transaction, {isOffline}) =>
            Future.error(failure),
      );
      final transaction = FakeTransactionRepository.sampleTransaction(id: 4);

      await expectLeftFailure(
        () => UpdateTransaction(repository)(transaction, isOffline: true),
        same(failure),
      );
    });

    test('UpdateTransaction maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeTransactionRepository(
        onUpdateTransaction: (transaction, {isOffline}) =>
            Future.error(Exception('boom')),
      );
      final transaction = FakeTransactionRepository.sampleTransaction(id: 4);

      await expectLeftFailure(
        () => UpdateTransaction(repository)(transaction, isOffline: true),
        isA<UnknownFailure>(),
      );
    });

    test('DeleteTransaction maps thrown Failure into Left', () async {
      const failure = NetworkFailure();
      final repository = FakeTransactionRepository(
        onDeleteTransaction: (id, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => DeleteTransaction(repository)(1, isOffline: true),
        same(failure),
      );
    });

    test('DeleteTransaction maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeTransactionRepository(
        onDeleteTransaction: (id, {isOffline}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => DeleteTransaction(repository)(1, isOffline: true),
        isA<UnknownFailure>(),
      );
    });
  });
}
