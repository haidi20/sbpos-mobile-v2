import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';

import 'package:transaction/presentation/screens/transaction_pos.screen.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/category.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

// Minimal fake ViewModel implementing the interface gunakand by the UI
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

  List<String> get availableCategories => ['Packet', 'All', 'Food'];

  String? lastSearch;

  @override
  void setSearchQuery(String q) {
    lastSearch = q;
    state = state.copyWith(searchQuery: q);
  }

  @override
  void setActiveCategory(String c) => state = state.copyWith(activeCategory: c);

  @override
  Future<void> getPacketsList() async {}

  @override
  Future<void> addPacketSelection(
      {required packet, required selectedItems}) async {}

  @override
  Future<void> onAddToCart(ProductEntity product) async {}

  List<ProductEntity> getFilteredProducts(
          {required List<ProductEntity> products}) =>
      products;

  void setCached(List<ProductEntity> p) => _cached = p;
}

void main() {
  testWidgets('TransactionPosScreen renders and search updates VM',
      (tester) async {
    final fakeVm = FakeTransactionPosViewModel();
    fakeVm.setCached([
      const ProductEntity(id: 1, name: 'Apple', price: 10000.0, qty: 20.0),
      const ProductEntity(id: 2, name: 'Banana', price: 5000.0, qty: 5.0),
    ]);

    await tester.pumpWidget(
      ProviderScope(overrides: [
        transactionPosViewModelProvider.overrideWith((ref) => fakeVm),
      ], child: const MaterialApp(home: TransactionPosScreen())),
    );

    await tester.pumpAndSettle();

    // search field present
    expect(find.byType(TextField), findsOneWidget);

    // type into search and verify fakeVm captured it
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pumpAndSettle();

    expect(fakeVm.lastSearch, 'apple');

    // pastikan tidak ada exception (tidak ada RenderFlex overflow, tidak ada kesalahan null-check, dll.)
    final ex = tester.takeException();
    expect(ex, isNull, reason: 'Unexpected exception during widget build/pump');
  });
}
