import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import 'package:transaction/presentation/components/transaction_detail.card.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';

class _FakeTxnRepo implements TransactionRepository {
  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
          {bool? isOffline}) async =>
      Right(<TransactionEntity>[]);

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Left(const UnknownFailure());

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Left(const UnknownFailure());

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
          {bool? isOffline, QueryGetTransactions? query}) async =>
      Right(<TransactionEntity>[]);

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
          {bool? isOffline}) async =>
      Left(const UnknownFailure());

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
          {bool? isOffline}) async =>
      Left(const UnknownFailure());

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Left(const UnknownFailure());

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
          {bool? isOffline}) async =>
      Left(const UnknownFailure());
}

class FakeTransactionPosViewModel extends TransactionPosViewModel {
  FakeTransactionPosViewModel()
      : super(
          CreateTransaction(_FakeTxnRepo()),
          UpdateTransaction(_FakeTxnRepo()),
          DeleteTransaction(_FakeTxnRepo()),
          GetTransactionActive(_FakeTxnRepo()),
        );

  List<ProductEntity> _cached = [];
  List<ProductEntity> get cachedProducts => _cached;
  void setCached(List<ProductEntity> c) => _cached = c;
}

void main() {
  testWidgets('TransactionDetailCard shows low-stock warning and packet badge',
      (tester) async {
    final fakeVm = FakeTransactionPosViewModel();
    fakeVm.setCached([
      const ProductEntity(
          id: 99,
          name: 'TestProduct',
          price: 10000.0,
          qty: 3.0,
          alertQuantity: 5.0),
    ]);

    final detail = TransactionDetailEntity(
      productId: 99,
      productName: 'TestProduct',
      productPrice: 10000,
      qty: 1,
      subtotal: 10000,
      packetId: 1,
      packetName: 'Paket A',
    );

    await tester.pumpWidget(ProviderScope(
        overrides: [
          transactionPosViewModelProvider.overrideWith((ref) => fakeVm),
        ],
        child: const MaterialApp(
            home: Scaffold(body: TransactionDetailCard(item: detail)))));

    await tester.pumpAndSettle();

    // should show packet badge
    expect(find.text('Paket'), findsOneWidget);

    // should show 'Stok rendah' or 'Stok menipis' depending on qty
    expect(find.textContaining('Stok rendah'), findsOneWidget);

    // pastikan tidak ada exception saat render (overflow, parent data, error null)
    final ex = tester.takeException();
    expect(ex, isNull, reason: 'Unexpected exception during widget build/pump');
  });
}
