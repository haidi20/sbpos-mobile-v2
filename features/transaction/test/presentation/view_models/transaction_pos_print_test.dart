import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.vm.dart';

class _FakeRepo implements TransactionRepository {
  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) async =>
      Right(transaction.copyWith(id: 1));

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
  }) async =>
      Right(transaction);

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction, {
    bool? isOffline,
  }) async =>
      Right(transaction);
}

class _FakePrinterFacade implements PrinterFacade {
  ReceiptPrintJob? lastJob;
  ReceiptPrintResult nextResult = const ReceiptPrintResult.success(
    'Struk berhasil dicetak',
  );

  @override
  Future<ReceiptPrintResult> printReceipt(ReceiptPrintJob job) async {
    lastJob = job;
    return nextResult;
  }

  @override
  Future<ReceiptPrintResult> printTestReceipt() async {
    return const ReceiptPrintResult.success('Test print berhasil');
  }

  @override
  Future<void> syncConfig(ReceiptPrinterConfig config) async {}
}

void main() {
  late TransactionPosViewModel viewModel;
late _FakePrinterFacade printerService;

  setUp(() {
    final repo = _FakeRepo();
    printerService = _FakePrinterFacade();
    viewModel = TransactionPosViewModel(
      CreateTransaction(repo),
      UpdateTransaction(repo),
      DeleteTransaction(repo),
      GetTransactionActive(repo),
      null,
      null,
      null,
      printerService,
    );
  });

  test('onPrintReceipt membangun print job dari transaction entity', () async {
    final transaction = TransactionEntity(
      id: 10,
      outletId: 1,
      sequenceNumber: 99,
      orderTypeId: 1,
      paymentMethod: 'cash',
      totalAmount: 25000,
      totalQty: 2,
      paidAmount: 30000,
      changeMoney: 5000,
      isPaid: true,
      date: DateTime(2026, 4, 1, 10, 30),
      details: [
        TransactionDetailEntity.fromProductEntity(
          transactionId: 10,
          product: const ProductEntity(
            id: 1,
            name: 'Americano',
            price: 15000,
          ),
          qty: 1,
        ),
        TransactionDetailEntity.fromProductEntity(
          transactionId: 10,
          product: const ProductEntity(
            id: 2,
            name: 'Croissant',
            price: 10000,
          ),
          qty: 1,
        ),
      ],
    );

    final job = viewModel.buildReceiptPrintJob(transaction);
    final result = await viewModel.onPrintReceiptJob(job);

    expect(result.isSuccess, isTrue);
    expect(printerService.lastJob, isNotNull);
    expect(printerService.lastJob!.title, equals('SB POS'));
    expect(printerService.lastJob!.lines.first.label, equals('No. Order'));
    expect(printerService.lastJob!.lines.first.value, equals('#99'));
    expect(
      printerService.lastJob!.lines.any((line) => line.label == 'Americano x1'),
      isTrue,
    );
    expect(
      printerService.lastJob!.lines.any((line) => line.label == 'Total'),
      isTrue,
    );
  });

  test('buildReceiptPrintJob menghasilkan footer dan ringkasan pembayaran',
      () {
    final transaction = TransactionEntity(
      id: 12,
      outletId: 1,
      sequenceNumber: 120,
      orderTypeId: 1,
      paymentMethod: 'qris',
      totalAmount: 18000,
      totalQty: 1,
      paidAmount: 20000,
      changeMoney: 2000,
      date: DateTime(2026, 4, 1, 13, 0),
    );

    final job = viewModel.buildReceiptPrintJob(transaction);

    expect(job.footer, equals('Terima kasih telah berbelanja'));
    expect(job.lines.any((line) => line.label == 'Bayar'), isTrue);
    expect(job.lines.any((line) => line.label == 'Kembalian'), isTrue);
  });

  test('onPrintReceipt meneruskan kegagalan service print', () async {
    printerService.nextResult = const ReceiptPrintResult.failure(
      'Printer tidak terhubung',
    );

    final transaction = TransactionEntity(
      id: 11,
      outletId: 1,
      sequenceNumber: 100,
      orderTypeId: 1,
      totalAmount: 10000,
      totalQty: 1,
      date: DateTime(2026, 4, 1),
    );

    final result = await viewModel.onPrintReceipt(transaction);

    expect(result.isSuccess, isFalse);
    expect(result.message, equals('Printer tidak terhubung'));
  });
}
