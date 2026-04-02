import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/domain/entitties/cashier_category.entity.dart';
import 'package:transaction/domain/entitties/edit_order_check.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/entitties/order_type.entity.dart';
import 'package:transaction/domain/entitties/ojol_option.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_action.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/check_transaction_qty.usecase.dart';
import 'package:transaction/domain/usecases/checkout_transaction.usecase.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_cashier_categories.usecase.dart';
import 'package:transaction/domain/usecases/get_cashier_ojol_options.usecase.dart';
import 'package:transaction/domain/usecases/get_cashier_order_types.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.vm.dart';

class _FakeLocalTransactionRepository implements TransactionRepository {
  TransactionEntity? storedTransaction;

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) async {
    storedTransaction = transaction.copyWith(id: 1);
    return Right(storedTransaction!);
  }

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
      const Right([]);

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
  }) async =>
      const Right([]);

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) async {
    storedTransaction = transaction;
    return Right(transaction);
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) async {
    storedTransaction = transaction;
    return Right(transaction);
  }
}

class _FakeCashierRemoteRepository implements CashierRemoteRepository {
  Either<Failure, bool> checkQtyResult = const Right(true);
  Either<Failure, List<CashierCategoryEntity>> categoriesResult = const Right([
    CashierCategoryEntity(id: 1, title: 'MAKANAN'),
  ]);
  Either<Failure, List<OrderTypeEntity>> orderTypesResult = const Right([
    OrderTypeEntity(id: 1, idServer: 1, name: 'Dine In'),
    OrderTypeEntity(id: 3, idServer: 3, name: 'Online'),
  ]);
  Either<Failure, List<OjolOptionEntity>> ojolOptionsResult = const Right([
    OjolOptionEntity(id: 'gofood', name: 'Go Food', feePercent: 20),
  ]);
  Either<Failure, TransactionEntity> checkoutResult = Right(
    TransactionEntity(
      idServer: 11,
      outletId: 1,
      sequenceNumber: 1,
      orderTypeId: 1,
      date: DateTime(2026, 4, 2, 10),
      totalAmount: 25000,
      totalQty: 1,
      status: TransactionStatus.lunas,
    ),
  );

  @override
  Future<Either<Failure, bool>> checkTransactionQty({
    required int productId,
    required int qty,
  }) async =>
      checkQtyResult;

  @override
  Future<Either<Failure, TransactionEntity>> checkoutTransaction(
    TransactionEntity transaction, {
    required bool isOnline,
  }) async =>
      checkoutResult;

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
      categoriesResult;

  @override
  Future<Either<Failure, List<TransactionEntity>>> getNotPaidTransactions() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<OjolOptionEntity>>> getOjolOptions() async =>
      ojolOptionsResult;

  @override
  Future<Either<Failure, List<OrderTypeEntity>>> getOrderTypes() async =>
      orderTypesResult;

  @override
  Future<Either<Failure, TransactionActionEntity>> requestCancelTransaction({
    required int transactionId,
    required String reason,
  }) async =>
      const Left(UnknownFailure());
}

void main() {
  late _FakeLocalTransactionRepository localRepository;
  late _FakeCashierRemoteRepository remoteRepository;
  late TransactionPosViewModel viewModel;

  setUp(() {
    localRepository = _FakeLocalTransactionRepository();
    remoteRepository = _FakeCashierRemoteRepository();
    viewModel = TransactionPosViewModel(
      CreateTransaction(localRepository),
      UpdateTransaction(localRepository),
      DeleteTransaction(localRepository),
      GetTransactionActive(localRepository),
      null,
      null,
      null,
      null,
      CheckTransactionQty(remoteRepository),
      CheckoutTransaction(remoteRepository),
      GetCashierCategories(remoteRepository),
      GetCashierOrderTypes(remoteRepository),
      GetCashierOjolOptions(remoteRepository),
    );
  });

  test('syncMasterData memperbarui kategori, order type, dan ojol', () async {
    await viewModel.syncMasterData();

    expect(viewModel.state.customCategories.first.title, equals('MAKANAN'));
    expect(viewModel.state.orderTypes.length, equals(2));
    expect(viewModel.ojolProviders.first.name, equals('Go Food'));
  });

  test('validateAndAddProductToCart menolak produk saat qty tidak valid',
      () async {
    remoteRepository.checkQtyResult =
        const Left(ServerValidation('Stok tidak cukup'));

    final result = await viewModel.validateAndAddProductToCart(
      product: const ProductEntity(id: 1, name: 'Americano', price: 25000),
    );

    result.fold(
      (failure) => expect(failure, isA<ServerValidation>()),
      (_) => fail('Expected Left result'),
    );
    expect(viewModel.state.details, isEmpty);
  });

  test('validateAndAddProductToCart memakai harga ojol saat order online',
      () async {
    viewModel.setOrderType(EOrderType.online);
    viewModel.setOjolProvider('Go Food');

    final result = await viewModel.validateAndAddProductToCart(
      product: const ProductEntity(
        id: 1,
        name: 'Americano',
        price: 20000,
        gofoodPrice: 25000,
      ),
    );

    expect(result.isRight(), isTrue);
    expect(viewModel.state.details.first.productPrice, equals(25000));
  });

  test('checkoutCurrentTransaction mengembalikan transaksi remote dan update lokal',
      () async {
    await viewModel.validateAndAddProductToCart(
      product: const ProductEntity(
        id: 1,
        name: 'Americano',
        price: 25000,
      ),
    );
    viewModel.setIsPaid(true);
    viewModel.setCashReceived(30000);

    final result = await viewModel.checkoutCurrentTransaction();

    result.fold(
      (_) => fail('Expected Right result'),
      (transaction) => expect(transaction.idServer, equals(11)),
    );
    expect(localRepository.storedTransaction?.idServer, equals(11));
  });
}
