import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/data/datasources/cashier_remote.data_source.dart';
import 'package:transaction/data/models/cashier_category.model.dart';
import 'package:transaction/data/models/edit_order_check.model.dart';
import 'package:transaction/data/models/ojol_option.model.dart';
import 'package:transaction/data/models/order_type_model.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/models/transaction_action.model.dart';
import 'package:transaction/data/repositories/cashier_remote.repository_impl.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';

class _FakeCashierRemoteDataSource extends CashierRemoteDataSource {
  _FakeCashierRemoteDataSource()
      : super(
          host: 'https://example.com',
          api: 'api',
          apiHelper: ApiHelper(),
        );

  Future<bool> Function({required int productId, required int qty})?
      onCheckTransactionQty;
  Future<List<CashierCategoryModel>> Function()? onGetCustomCategories;
  Future<List<OrderTypeModel>> Function()? onGetOrderTypes;
  Future<List<OjolOptionModel>> Function()? onGetOjolOptions;
  Future<TransactionModel> Function(
    TransactionEntity transaction, {
    required bool isOnline,
  })? onCheckoutTransaction;
  Future<List<TransactionModel>> Function()? onGetNotPaidTransactions;
  Future<TransactionActionModel> Function({
    required int transactionId,
    required String reason,
  })? onRequestCancelTransaction;
  Future<TransactionActionModel> Function({
    required int transactionId,
    required String otp,
  })? onConfirmCancelTransaction;
  Future<EditOrderCheckModel> Function(int transactionId)? onCheckEditOrder;

  @override
  Future<bool> checkTransactionQty({
    required int productId,
    required int qty,
  }) async {
    final handler = onCheckTransactionQty;
    if (handler == null) {
      return true;
    }
    return handler(productId: productId, qty: qty);
  }

  @override
  Future<TransactionModel> checkoutTransaction(
    TransactionEntity transaction, {
    required bool isOnline,
  }) async {
    final handler = onCheckoutTransaction;
    if (handler == null) {
      return TransactionModel(
        idServer: 10,
        outletId: transaction.outletId,
        sequenceNumber: transaction.sequenceNumber,
        orderTypeId: transaction.orderTypeId,
        date: transaction.date,
        totalAmount: transaction.totalAmount,
        totalQty: transaction.totalQty,
        status: transaction.status,
      );
    }
    return handler(transaction, isOnline: isOnline);
  }

  @override
  Future<EditOrderCheckModel> checkEditOrder(int transactionId) async {
    final handler = onCheckEditOrder;
    if (handler == null) {
      return const EditOrderCheckModel(
        canEdit: true,
        message: 'ok',
      );
    }
    return handler(transactionId);
  }

  @override
  Future<TransactionActionModel> confirmCancelTransaction({
    required int transactionId,
    required String otp,
  }) async {
    final handler = onConfirmCancelTransaction;
    if (handler == null) {
      return const TransactionActionModel(success: true, message: 'ok');
    }
    return handler(transactionId: transactionId, otp: otp);
  }

  @override
  Future<List<CashierCategoryModel>> getCustomCategories() async {
    final handler = onGetCustomCategories;
    if (handler == null) {
      return const [CashierCategoryModel(id: 1, title: 'MAKANAN')];
    }
    return handler();
  }

  @override
  Future<List<TransactionModel>> getNotPaidTransactions() async {
    final handler = onGetNotPaidTransactions;
    if (handler == null) {
      return [
        TransactionModel(
          idServer: 99,
          outletId: 1,
          sequenceNumber: 10,
          orderTypeId: 1,
          date: DateTime(2026, 4, 2, 14),
          totalAmount: 15000,
          totalQty: 1,
        ),
      ];
    }
    return handler();
  }

  @override
  Future<List<OjolOptionModel>> getOjolOptions() async {
    final handler = onGetOjolOptions;
    if (handler == null) {
      return const [
        OjolOptionModel(id: 'gofood', name: 'Go Food', feePercent: 20),
      ];
    }
    return handler();
  }

  @override
  Future<List<OrderTypeModel>> getOrderTypes() async {
    final handler = onGetOrderTypes;
    if (handler == null) {
      return [
        OrderTypeModel(id: 1, name: 'Dine In'),
      ];
    }
    return handler();
  }

  @override
  Future<TransactionActionModel> requestCancelTransaction({
    required int transactionId,
    required String reason,
  }) async {
    final handler = onRequestCancelTransaction;
    if (handler == null) {
      return const TransactionActionModel(success: true, message: 'OTP dikirim');
    }
    return handler(transactionId: transactionId, reason: reason);
  }
}

void main() {
  late _FakeCashierRemoteDataSource remote;
  late CashierRemoteRepositoryImpl repository;

  setUp(() {
    remote = _FakeCashierRemoteDataSource();
    repository = CashierRemoteRepositoryImpl(remote: remote);
  });

  test('getCustomCategories memetakan model menjadi entity', () async {
    final result = await repository.getCustomCategories();

    result.fold(
      (_) => fail('Expected Right result'),
      (categories) => expect(categories.first.title, equals('MAKANAN')),
    );
  });

  test('checkTransactionQty memetakan server validation ke Left', () async {
    remote.onCheckTransactionQty = ({
      required productId,
      required qty,
    }) =>
        Future.error(const ServerValidation('Stok tidak cukup'));

    final result = await repository.checkTransactionQty(
      productId: 1,
      qty: 9,
    );

    result.fold(
      (failure) => expect(failure, isA<ServerValidation>()),
      (_) => fail('Expected Left result'),
    );
  });

  test('checkoutTransaction memetakan model transaksi remote menjadi entity',
      () async {
    final result = await repository.checkoutTransaction(
      TransactionEntity(
        outletId: 1,
        sequenceNumber: 10,
        orderTypeId: 1,
        date: DateTime(2026, 4, 2, 10),
        totalAmount: 25000,
        totalQty: 1,
      ),
      isOnline: false,
    );

    result.fold(
      (_) => fail('Expected Right result'),
      (transaction) => expect(transaction.idServer, equals(10)),
    );
  });

  test('getNotPaidTransactions memetakan list model menjadi entity', () async {
    final result = await repository.getNotPaidTransactions();

    result.fold(
      (_) => fail('Expected Right result'),
      (transactions) => expect(transactions.first.idServer, equals(99)),
    );
  });

  test('confirmCancelTransaction memetakan response aksi', () async {
    final result = await repository.confirmCancelTransaction(
      transactionId: 7,
      otp: '123456',
    );

    result.fold(
      (_) => fail('Expected Right result'),
      (action) => expect(action.success, isTrue),
    );
  });

  test('requestCancelTransaction memetakan response aksi OTP', () async {
    final result = await repository.requestCancelTransaction(
      transactionId: 7,
      reason: 'Customer berubah pikiran',
    );

    result.fold(
      (_) => fail('Expected Right result'),
      (action) {
        expect(action.success, isTrue);
        expect(action.message, contains('OTP'));
      },
    );
  });

  test('checkEditOrder memetakan response edit order', () async {
    final result = await repository.checkEditOrder(77);

    result.fold(
      (_) => fail('Expected Right result'),
      (entity) => expect(entity.canEdit, isTrue),
    );
  });
}
