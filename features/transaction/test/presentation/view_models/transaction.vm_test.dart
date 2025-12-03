import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:product/domain/entities/product_entity.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';

class FakeRepo implements TransactionRepository {
  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    final created = TransactionEntity(
      id: 1,
      warehouseId: transaction.warehouseId,
      sequenceNumber: transaction.sequenceNumber,
      orderTypeId: transaction.orderTypeId,
      date: transaction.date,
      totalAmount: transaction.totalAmount,
      totalQty: transaction.totalQty,
      notes: transaction.notes,
      details: (transaction.details ?? [])
          .map((d) => d.copyWith(transactionId: 1))
          .toList(),
    );
    return Right(created);
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

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions({
    bool? isOffline,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline}) async {
    return const Left(UnknownFailure());
  }

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
      {bool? isOffline}) async {
    return const Left(UnknownFailure());
  }

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
      {bool? isOffline}) async {
    return const Right([]);
  }
}

class _FakeRepoWithLocalTransaction extends FakeRepo {
  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline}) async {
    if (id == 1) {
      final tx = TransactionEntity(
        id: 1,
        warehouseId: 8,
        sequenceNumber: 0,
        orderTypeId: 1,
        date: DateTime.now(),
        totalAmount: 10000,
        totalQty: 1,
        details: [
          const TransactionDetailEntity(
            productId: 11,
            productName: 'Product A',
            productPrice: 10000,
            qty: 1,
            subtotal: 10000,
            transactionId: 1,
          ),
        ],
      );
      return Right(tx);
    }
    return const Left(UnknownFailure());
  }
}

void main() {
  group('TransactionPosViewModel', () {
    late TransactionPosViewModel vm;
    late FakeRepo repo;

    setUp(() {
      repo = FakeRepo();
      vm = TransactionPosViewModel(
        CreateTransaction(repo),
        UpdateTransaction(repo),
        DeleteTransaction(repo),
        GetTransactionActive(repo),
      );
    });

    test('onAddToCart adds detail to state', () async {
      const product = ProductEntity(id: 10, name: 'Test', price: 5000.0);
      expect(vm.state.details, isEmpty);
      await vm.onAddToCart(product);
      expect(vm.state.details.length, 1);
      final detail = vm.state.details.first;
      expect(detail.productId, equals(10));
      expect(detail.qty, equals(1));
    });

    test('initializes by loading local transaction when available (offline)',
        () async {
      final localRepo = _FakeRepoWithLocalTransaction();
      final vmLocal = TransactionPosViewModel(
        CreateTransaction(localRepo),
        UpdateTransaction(localRepo),
        DeleteTransaction(localRepo),
        GetTransactionActive(localRepo),
      );

      await Future.delayed(const Duration(milliseconds: 10));
      expect(vmLocal.state.transaction, isNotNull);
      expect(vmLocal.state.transaction?.id, equals(1));
      expect(vmLocal.state.details, isNotEmpty);
      expect(vmLocal.state.details.first.productId, equals(11));
    });

    test(
        'onStoreLocal creates transaction locally and assigns transactionId to details',
        () async {
      const product = ProductEntity(id: 11, name: 'Product A', price: 10000.0);

      final detail = TransactionDetailEntity(
        productId: product.id,
        productName: product.name,
        productPrice: product.price!.toInt(),
        qty: 1,
        subtotal: product.price!.toInt(),
      );
      vm.state = vm.state.copyWith(transaction: null, details: [detail]);

      await vm.onStoreLocal(product: product);

      expect(vm.state.transaction, isNotNull);
      expect(vm.state.transaction?.toModel().toJson()['id'], equals(1));

      expect(vm.state.details, isNotEmpty);
      for (var d in vm.state.details) {
        final tid = d.transactionId ?? d.toModel().toJson()['transaction_id'];
        expect(tid, equals(1));
      }
    });
  });
}
